
-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP VIEW IF EXISTS Standings;
DROP VIEW IF EXISTS total_matches;
DROP VIEW IF EXISTS Wins;
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
	victor int,
	primary key(id)
);

-- Show WINS for each player
create VIEW Wins as
	select Players.id, count(matches.red_team) as win
	from Players left join (Select * from Matches where victor > 0) as Matches
	on Players.id = matches.blue_team
	group by Players.id;

-- Shows # of Matches for each player
create view total_matches as
	select players.id, count(matches.red_team) as num
	from players left join matches
	on players.id = matches.blue_team
	group by players.id;

-- Shows overall standings of the tournament
create view Standings as
	select players.id, players.name, Wins.win as wins, total_matches.num as matches
	from Players,Wins,total_matches
	where players.id = wins.id and wins.id = total_matches.id;
