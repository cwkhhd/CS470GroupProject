USE WorldCup;

CREATE TABLE Match
(
Match_No INT,
Team_A VARCHAR(50),
Team_B VARCHAR(50),
Match_Type VARCHAR(30),
Result_A INT,
Result_B INT,
Stadium VARCHAR(30),
Time TIMESTAMP
);

ALTER TABLE Match
ADD Primary Key(Match_No);