create schema worldcup;
use worldcup;

create table Team
(
	Team_Name 			varchar(30) not null,
    	
    	Manager				varchar(30) not null,
    	Player				varchar(30) not null,
    	Captain				varchar(30) not null,

    
    	primary key 			(Team_Name),
    	unique				(Team_Name)
);

CREATE TABLE Stage(Stage_Name varchar(30));


	INSERT INTO Stage(Stage_Name) VALUES 
	('Group 1'), 
	('Group 2'), 
	('Group 3'),
	('Group 4'), 
	('Group 5'),
	('Group 6'),
	('Group 7'), 
	('Group 8'), 
	('Sixteen'), 
	('Quarter-Finals'), 
	('Semi-Finals'),
	('Finals');
	
	ALTER TABLE Stage
		Add Primary Key(Stage_Name);

    
create table Matches
(
	Match_Number			integer not null,
    	Team_1				varchar(50) not null,
    	Team_2				varchar(50) not null,
    	Score_1				integer not null,
    	Score_2				integer not null,
    	Winner				varchar(50),
		Stadium				varchar(30) not null,
    	Match_time			datetime,
        Match_type			varchar(30),
        
    	Primary key			(Match_Number),
    	Unique				(Match_Number)
);

alter table Matches
	ADD constraint fk_match_type foreign key (Match_type) references Stage(Stage_Name);
    
create table Player
	(First_Name varchar(30), Last_Name varchar(30), Nick_Name varchar(30),
    Number int, Team_Name varchar(50), Goals int);
        
Alter Table Player
	ADD constraint pk_Player primary key (Number, Team_Name);

Alter Table Player  
	ADD constraint fk_Player foreign key (Team_Name) references Team(Team_Name);

create table Position_Constraints
	(Position varchar(30) primary key);
    
insert into Position_Constraints
values ("LB"), ("RB"), ("CM"), ("DM"), ("AM"), ("SS"), ("CF"), ("LW"), ("RW");
    
create table Player_Position

	( Number int, TName varchar(30), Position varchar(30));

Alter table Player_Position
	Add constraint primary key (Number,TName, Position);
    
Alter Table Player_Position
	ADD constraint fk_Player_Position foreign key (Number, TName) references Player (Number, Team_Name) On delete cascade;
    
Alter table Player_Position
	add constraint fk_Position_Constriaints foreign key (Position) references Position_Constraints (Position);

create table Award_Constraints
	(Award varchar(30) primary key);

Insert into Award_Constraints
	values ("Golden Ball"), ("Golden Boot"), ("Golden Glove"), ("Man of the Match");

create table Player_Award
	(Number int, TName varchar(30), Award varchar(30));
    
alter table Player_Award
	ADD constraint pk_Player_Award Primary Key (Number, TName, Award);
    
ALter table Player_Award
	ADD constraint fk_Player_Award foreign key (Number, TName) references Player (Number, Team_Name) on delete cascade;

Alter table Player_Award
	ADD constraint fk_Award_Exists foreign key (Award) references Award_Constraints (Award);

alter table Matches add constraint fk1_TeamName
    foreign key (Team_1) references Team(Team_Name);

alter table Matches add constraint fk2_TeamName
    foreign key (Team_2) references Team(Team_Name);
    
    