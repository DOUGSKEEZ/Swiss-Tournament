#!/usr/bin/env python
# 
# tournament.py -- implementation of a Swiss-system tournament

import psycopg2

def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")

def deleteMatches():
    """Remove all the match records from the database."""
    conn = connect()
    c = conn.cursor()
    c.execute("DELETE from matches;")
    conn.commit()
    conn.close()

def deletePlayers():
    """Remove all the player records from the database."""
    conn = connect()
    c = conn.cursor()
    c.execute("DELETE from players;")
    conn.commit()
    conn.close()

def countPlayers():
    """Returns the number of players currently registered."""
    conn = connect()
    c = conn.cursor()
    c.execute("SELECT count(id) as num from players;")
    num_players = c.fetchall()
    for row in num_players:
        return row[0]
    conn.close()

def registerPlayer(name):
    """Adds a player to the tournament database.
  
    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)
  
    Args:
      name: the player's full name (need not be unique).
    """
    conn = connect()
    c = conn.cursor()
    c.execute("INSERT into players (name) values (%s)", (name,))
    conn.commit()
    conn.close()


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.
    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.
    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    db = connect()
    c = db.cursor()
    c.execute("SELECT id,name,numwins,totalmatch FROM standings")
    rows = c.fetchall()
    db.close();
    return rows


def reportMatch(winner, loser):
    """Records the outcome of a single match between two players.
    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
      ATTENTION^^ ATTENTION^^ ATTENTION^^^^^^^^^
    """
    db = connect()
    c = db.cursor()
    c.execute("INSERT INTO Matches (blue_team,red_team,victor) VALUES (%s,%s,%s)",(winner,loser,winner))
    db.commit()
    db.close();
 
 
def swissPairings():
    """Returns a list of pairs of players for the next round of a match.
  
    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.
  
    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    db = connect()
    c = db.cursor()
    c.execute("SELECT * FROM Standings;")
    list_players = c.fetchall()
    db.commit()
    db.close()
 
    pairing = []

    for i, player in enumerate(list_players):
        if i%2 == 0:
            #Match = ([(even#Rank), even#Rank_name],[(even#Rank)+1, (even#Rank+1)_name]
            match = (list_players[i][0],
                     list_players[i][1],
                     list_players[i+1][0],
                     list_players[i+1][1])

            pairing.append(match)
    return pairing