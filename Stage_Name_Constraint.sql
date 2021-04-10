use WorldCup;

CREATE TABLE Stage_Names(Stage_name varchar(30));

INSERT INTO Stage_Names(Stage_name) VALUES 
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

ALTER TABLE Stage_Names
	Add Primary Key(Stage_Name);
    

ALTER TABLE Stage 
	ADD constraint Stage_name FOREIGN KEY Stage(Match_Type) REFERENCES Stage_Names(Stage_Name); 
   
