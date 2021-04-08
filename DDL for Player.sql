use WorldCup;
create table Player
	(First_Name varchar(30), Last_Name varchar(30), Nick_Name varchar(30),
    Number int, Team_Name varchar(50), Goals int);

Alter Table Player
	ADD primary key (Number, Team_Name);


Alter Table Player 
	ADD foreign key (Team_Name) references Team(Team_Name);



create table Player_Position
	( Number int, TName varchar(30), Position varchar(30));

Alter table Player_Position
	Add primary key (TName, Position);
    
Alter Table Player_Position
	ADD foreign key (Number, TName) references Player (Number, Team_Name);

create table Player_Award
	(Number int, TName varchar(30), Award varchar(30));
    
alter table Player_Award
	ADD Primary Key (TName, Award);
    
ALter table Player_Award
	ADD foreign key (Number, TName) references Player (Number, Team_Name);
    

    
