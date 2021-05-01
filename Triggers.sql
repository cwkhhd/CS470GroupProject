# there cannot be more than 22 players per team
use worldcup
delimiter $$
create trigger tnumplayers 
before insert on Player 
for each row 
begin 
if((select count(*) from Player where TeamName = inserted.TeamName )>21 )

Then 
signal sqlstate '45000'
	set message_text = 'too many players on this team';
    
end if;

end$$
delimiter ;

#If team A is in group stage x, then team A cannot also be in group stage y where x != y

use worldcup;

delimiter $$
create trigger groupexclusion
before insert on Matches
for each row

begin
if(inserted.Match_type like '%Group%')
then
create temporary table ttd
select distinct Match_type 
from (select Match_type from Matches where (inserted.Team_1 = Team_1 or inserted.Team_1 = Team_2)
union select Match_type from Matches where (inserted.Team_2 = Team_2 or inserted.Team_2 = Team_1))as tempc;

if((select count(*) from ttd) > 1)
then

drop temporary table ttd;

signal sqlstate '45000'
	set message_text = 'This team is already in a different group stage';
else
drop temporary table ttd;
end if;
end if;
end $$

delimiter ;

# There cannot be more than 6 matches per group
delimiter $$
create trigger groupmatchnumber
before insert on Matches
for each row
begin

if(inserted.Match_type like '%Group%')
then
if((select count(*) from Matches where Match_type = inserted.Match_type) > 5)
then 

signal sqlstate '45000'
	set message_text = 'There are already 6 matches in this group stage';

end if;
end if;
end $$
delimiter ;


# A team must have the top 2 scores in their group stage to proceed to 16 round



delimiter $$
create trigger stage16progression
before insert on Matches
for each row
begin

set @fteam1 = (select distinct Match_type from matches where( Match_type like '%Group%' and (inserted.Team_1 = Team_1 or inserted.Team_1 = Team_1))limit 1);

set @fteam2 = (select distinct Match_type from matches where( Match_type like '%Group%' and (inserted.Team_2 = Team_1 or inserted.Team_1 = Team_2))limit 1);

set @teamscore1 = 	(select count(score)
    from
    
		(select count(*)*3 as score from
        matches where((Team_1 = inserted.Team_1 or Team_2 = inserted.Team_1) and (Winner = inserted.Team_1))
        union
        select count(*) as score from
        matches where((Team_1 = inserted.Team_1 or Team_2 = inserted.Team_1) and (Winner is null)))
		as temp 
        limit 1);

set @teamscore2 = 	(select count(score)
    from
    
		(select count(*)*3 as score from
        matches where((Team_1 = inserted.Team_2 or Team_2 = inserted.Team_2) and (Winner = inserted.Team_2))
        union
        select count(*) as score from
        matches where((Team_1 = inserted.Team_2 or Team_2 = inserted.Team_2) and (Winner is null)))
		as temp 
        limit 1);

create temporary table temp_table1 
select *
from (select  Team, count(Score) as Score
    from ((select Winner as Team, count(Winner)*3 as Score from Matches where (Match_type = @fteam1 AND Winner is not null) group by Winner) 
    union (select Team_1 as Team, count(Team_1) as Score from Matches where (Match_type = @fteam1 AND Winner is null) group by Team_1) 
    union (select Team_2 as Team, count(Team_2) as Score from Matches where (Match_type = @fteam1 AND Winner is null) group by Team_2) ) as temp
    group by Team
    order by Score desc) as t1
    limit 2;
    
create temporary table temp_table2 
select *
from (select  Team, count(Score) as Score
    from ((select Winner as Team, count(Winner)*3 as Score from Matches where (Match_type = @fteam2 AND Winner is not null) group by Winner) 
    union (select Team_1 as Team, count(Team_1) as Score from Matches where (Match_type = @fteam2 AND Winner is null) group by Team_1) 
    union (select Team_2 as Team, count(Team_2) as Score from Matches where (Match_type = @fteam2 AND Winner is null) group by Team_2) ) as temp
    group by Team
    order by Score desc) as t2
    limit 2;

if(@fteam1 not in (select Team from temp_table1) or @fteam2 not in (select Team from temp_table2))
then
drop temporary table temp_table1;
drop temporary table temp_table2;
signal sqlstate '45000'
	set message_text = 'This group doesnt qualify for this stage!';
else
drop temporary table temp_table1;
drop temporary table temp_table2;
end if;
end $$
delimiter ;

#there cannot be more than 4 teams per group stage
delimiter $$
create trigger numteamsingroup
before insert on Matches
for each row
begin
if(inserted.Match_type like '%Group%')
then
create temporary table tempa
select distinct team
from (select distinct Team_1 as team from Matches where Match_type = inserted.Match_type
union select distinct Team_2 as team from Matches where Match_type = inserted.Match_type
union select Team_1 as team from inserted
union select Team_2 as team from inserted) as tt1;

if((select count(*) from tempa) > 4)

then 
drop temporary table tempa;
signal sqlstate '45000'
	set message_text = 'There are already 4 teams in this group stage';
else
drop temporary table tempa;
end if;
end if;
end $$
delimiter ;

# there can only be 16 team in stage 16
delimiter $$
create trigger groupmatteamnum
before insert on Matches
for each row
begin

if(inserted.Match_type = "Sixteen")
then

create temporary table tempb
select distinct team
from (select Team_1 as team from Matches where Match_type = "Sixteen"
union select Team_2 as team from Matches where Match_type = "Sixteen"
union select Team_1 as team from inserted
union select Team_2 as team from inserted) as tt2;

if((select count(*) from tempb) > 16)
then 

drop temporary table tempb;

signal sqlstate '45000'
	set message_text = 'There are already 16 teams in this rung';
else
drop temporary table tempb;

end if;
end if;
end $$
delimiter ;

#there cannot be more than 8 games from stage 16
delimiter $$
create trigger sixteennummatches
before insert on Matches
for each row
begin

if((select count(*) from Matches where Match_type = "Sixteen") >= 8)
then 

signal sqlstate '45000'
	set message_text = 'There are already 8 games in sixteen stage';

end if;
end $$
delimiter ;

#there cannot be more than 8 teams in quarter finals

delimiter $$
create trigger quarternumteam
before insert on Matches
for each row
begin

if(inserted.Match_type = "Quarter-Finals")
then

create temporary table tempb
select distinct team
from (select Team_1 as team from Matches where Match_type = "Quarter-Finals"
union select Team_2 as team from Matches where Match_type = "Quarter-Finals"
union select Team_1 as team from inserted
union select Team_2 as team from inserted) as tt2;

if((select count(*) from tempb) > 8)
then 

drop temporary table tempb;

signal sqlstate '45000'
	set message_text = 'There are already 8 teams in the quarter finals';
else
drop temporary table tempb;

end if;
end if;
end $$
delimiter ;

# you can't play yourself
delimiter $$
create trigger noself
before insert on Matches
for each row
begin

if(inserted.Team_1 = Inserted.Team_2)
then 

signal sqlstate '45000'
	set message_text = 'You can\'t play yourself dummy';

end if;
end $$
delimiter ;

#there cannot be more than 4 games in quarter finals

delimiter $$
create trigger quarternummatches
before insert on Matches
for each row
begin

if((select count(*) from Matches where Match_type = "Quarter-Finals") >= 4)
then 

signal sqlstate '45000'
	set message_text = 'There are already 4 games in sixteen stage';

end if;
end $$
delimiter ;

#There cannot be more than 4 teams in the semifinal
delimiter $$
create trigger semnumteam
before insert on Matches
for each row
begin

if(inserted.Match_type = "Semi-Finals")
then

create temporary table tempq
select distinct team
from (select Team_1 as team from Matches where Match_type = "Semi-Finals"
union select Team_2 as team from Matches where Match_type = "Semi-Finals"
union select Team_1 as team from inserted
union select Team_2 as team from inserted) as ttf;

if((select count(*) from tempq) > 4)
then 

drop temporary table tempq;

signal sqlstate '45000'
	set message_text = 'There are already r teams in the semi finals';
else
drop temporary table tempq;

end if;
end if;
end $$
delimiter ;

#There cannot be more than 2 games in the semi-finals

delimiter $$
create trigger seminummatches
before insert on Matches
for each row
begin

if((select count(*) from Matches where Match_type = "Semi-Finals") >= 2)
then 

signal sqlstate '45000'
	set message_text = 'There are already 2 games in semi finals';

end if;
end $$
delimiter ;

#there cannot be more than 1 game called finals

delimiter $$
create trigger finalnummatches
before insert on Matches
for each row
begin

if((select count(*) from Matches where Match_type = "Finals") >= 1)
then 

signal sqlstate '45000'
	set message_text = 'Final has been played';

end if;
end $$
delimiter ;