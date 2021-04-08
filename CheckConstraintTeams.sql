use WorldCup;
ALTER TABLE Matches
	ADD  CHECK(Team_A <> Team_B);
