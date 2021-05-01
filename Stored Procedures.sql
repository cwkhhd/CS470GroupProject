use worldcup;

-- what teams made it to the knockout rounds
delimiter $$
create procedure sp_knockout_teams ()
begin
	select Team_1, Team_2
    from matches 
    where Match_type = 'Finals';
end$$
delimiter ;


-- what is the total wins, losses, and ties for each team?

delimiter $$
create procedure sp_win_loss (IN team varchar(30))
begin
	select count(wins), count(losses), count(tie)
from (

(select count(*) as wins, 0 as losses, 0 as tie
from matches
where winner = team)
union
	(select 0 as count, count(*) as wins, 0 as tie 
    from matches
    where winner <> team AND (team_1 = team or team_2 = team))
union
	(select 0 as count, 0 as wins, count(*) as tie
    from matches
    where (team_1= team or team_2 = team) and winnter is null)
   
) as temp_table;

end$$
delimiter ;

-- how many games ended in a tie

delimiter $$
create procedure sp_tie_game ()
begin
    select count(*)
    from matches
    where winner is null;
    
end$$
    delimiter ;
    
-- what was the highest score of all teams?

delimiter $$
create procedure sp_high_score ()
begin
  select team, max(score)
  from (select team_1 as team, score_1 as score
  from Matches
  union
  select team_2 as team, score_2 as score
  from Matches
  ) as temp;
end$$
    delimiter ;


    

delimiter $$
create procedure sp_low_score ()
begin
  select team, min(score)
  from (select team_1 as team, score_1 as score
  from matches
  union
  select team_2 as team, score_2 as score
  from matches
  ) as temp;
end$$
    delimiter ;
    
-- what group is team x in?

delimiter $$
create procedure sp_team_group (IN team varchar(50))
begin
	select distinct Match_Type
    from matches inner join match_type on matches.Match_Number = match_type.Match_number
    where (team = Team_1 or team = Team_2) and Match_Type like '%group%';
end$$
    delimiter ;

-- score for group phase

delimiter $$
create procedure sp_group_score (IN team varchar(50))
begin
	select count(score)
    from
    
		(select count(*)*2 as score from
        matches where((Team_1 = team or Team_2 = team) and (Winner = team))
        union
        select count(*) as score from
        matches where((Team_1 = team or Team_2 = team) and (Winner is null)))
		as temp;
end$$
    delimiter ;

        
        
# what teams are in group x

delimiter $$
create procedure sp_teamsingroupstage (IN groupname varchar(30))
begin
if(groupname like '%group%' and (select count(*) from stage where Stage_Name = groupname)>0)
then
begin
select distinct Team from (select Team_1 as Team from Matches where Match_type = groupname 
union select Team_2 as Team from Matches where Match_type = groupname) as temp;
end;
end if;
end$$
    delimiter ;



select Winner as Team, count(Winner)*2 as Score from Matches where (Match_type = groupname AND Winner is not null) group by Winner;

# group score for all teams: 

delimiter $$
create procedure sp_all_team_group_score (IN groupname varchar(30))
begin
if(groupname like '%group%' and (select count(*) from stage where Stage_Name = groupname)>0)
then
begin
	select  Team, count(Score) as Score
    from ((select Winner as Team, count(Winner)*2 as Score from Matches where (Match_type = groupname AND Winner is not null) group by Winner) 
    union (select Team_1 as Team, count(Team_1) as Score from Matches where (Match_type = groupname AND Winner is null) group by Team_1) 
    union (select Team_2 as Team, count(Team_2) as Score from Matches where (Match_type = groupname AND Winner is null) group by Team_2) ) as temp
    group by Team
    order by Score desc;

end;
end if;
end$$
    delimiter ;
    
     
    
    
    
-- team roster

delimiter $$
create procedure sp_roster (IN team varchar(50))
begin
	select First_Name, Last_Name, Number as Jersey_Number
    from Player
    where Team_Name = team;
end$$
    delimiter ;