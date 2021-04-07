use WorldCup;

CREATE TABLE Team(
Team_Name varchar(50),
Nick_name varchar(30),
Manager varchar(30),
Captain varchar(30),
#jersey will be an image file
Jersey blob);

ALTER TABLE Team
	ADD Primary Key(Team_Name);
    
    