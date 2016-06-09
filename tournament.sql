
-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP VIEW IF EXISTS Standings;
DROP VIEW IF EXISTS gamelog;
DROP VIEW IF EXISTS Blue_Team_Count;
DROP VIEW IF EXISTS Red_Team_Count;
DROP VIEW IF EXISTS Winlist;
DROP VIEW IF EXISTS Matches_Played;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Players;


-- PLAYERS TABLE
create table Players (
	id serial,
	name text,
	--wins integer,
	primary key(id)
);

-- MATCHES TABLE
create table Matches(
	id serial,
	red_team int references players(id),
	blue_team int references players(id),
	victor int references players(id),
	primary key(id)
);

-- Shows Matches Played (will not show match as complete if no victor = not complete)
create VIEW Matches_Played as
	SELECT Matches.ID, Matches.Blue_Team, Matches.Red_Team, Matches.Victor
	FROM Matches
	WHERE ((Matches.Victor)>0);


-- Show WINS for each player
create VIEW Winlist as
	SELECT Players.ID, Count(Matches_Played.Victor) AS numwins
	FROM Players LEFT JOIN Matches_Played ON Players.ID=Matches_Played.Victor
	GROUP BY Players.ID;


-- Red_Team View
--create view Red_Team_Count as
--	SELECT Players.ID, Count(Matches.red_team) AS games_as_red
--FROM Players LEFT JOIN Matches ON Players.ID=Matches.Red_Team
--GROUP BY Players.ID;

-- Blue Team View
--create VIEW Blue_Team_Count as
--	SELECT Players.ID, Count(Matches.blue_team) AS games_as_blue
--	FROM Players LEFT JOIN Matches ON Players.ID=Matches.Blue_Team
--	GROUP BY players.id;

-- Join list of Red and Blue to count total showing completed matches for each player (returns null if not played a game)
create view gamelog as
	SELECT playerid, Count(*) as totalmatch
		FROM (
				SELECT red_team as playerid
				FROM Matches
				UNION ALL
				SELECT blue_team
				FROM Matches
			) as gamecount
		group by playerid;

create view Standings as
Select results.id as id, results.name as name, results.numwins as numwins, coalesce(gamelog.totalmatch, 0) as totalmatch
from (select players.id, players.name, winlist.numwins 
from players, winlist 
where players.id = winlist.id) as results 
left join gamelog
on results.id = gamelog.playerid
order by numwins desc;
