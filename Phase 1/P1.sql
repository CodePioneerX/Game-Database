-- *********************************************************************************************************************************************************************************************
-- *SOEN 363 PROJECT 1																																										   *
-- *Group: 23																																												   *
-- *Members: Haris Mahmood - 40135271 , Zayneb Mehdi - 40109417, Louisa-Lina Meziane - 40133119, Carson Senthilkumar – 40173515																   *
-- *Topic: Database for Games, holds data of games from the past all the way to the present, and includes games 2 years from the present time anything after that is considered to be invalid. *
-- *********************************************************************************************************************************************************************************************

CREATE DATABASE IF NOT EXISTS GAMES;
USE GAMES;

CREATE TABLE Games (
    game_id INT PRIMARY KEY AUTO_INCREMENT,
    nameOfGames VARCHAR(512),
    released_date DATE,
	rating DECIMAL(10, 5) CHECK (rating >= 0.0 AND rating <= 100.0),
    summary TEXT
    
);

-- Is A relationship, where ActionGames is a Game
CREATE TABLE ActionGames (
    game_id INT PRIMARY KEY,
    FOREIGN KEY (game_id) REFERENCES Games(game_id)
);


CREATE TABLE Platforms (
    platform_id INT PRIMARY KEY AUTO_INCREMENT,
    nameOfPlatform VARCHAR(512)
);

CREATE TABLE Genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    nameOfGenres VARCHAR(255)
);

-- Example of weak entity 
CREATE TABLE GamePlatforms (
    game_id INT,
    platform_id INT,
    PRIMARY KEY (game_id, platform_id),
    FOREIGN KEY (game_id) REFERENCES Games(game_id),
    FOREIGN KEY (platform_id) REFERENCES Platforms(platform_id)
);

-- Example of weak entity 
CREATE TABLE GameGenres (
    game_id INT,
    genre_id INT,
    PRIMARY KEY (game_id, genre_id),
    FOREIGN KEY (game_id) REFERENCES Games(game_id),
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);



-- Views
-- Example View: ActionGamesView
CREATE VIEW ActionGamesView AS
SELECT G.game_id, G.nameOfGames, G.released_date, G.rating, G.summary
FROM Games G
JOIN ActionGames AG ON G.game_id = AG.game_id;


-- Example View: GameDetailsView
CREATE VIEW GameDetailsView AS
SELECT
    G.game_id,
    G.nameOfGames,
    G.released_date,
    G.rating,
    G.summary,
    (
        SELECT GROUP_CONCAT(P.nameOfPlatform ORDER BY P.nameOfPlatform ASC SEPARATOR ', ')
        FROM GamePlatforms GP
        JOIN Platforms P ON GP.platform_id = P.platform_id
        WHERE GP.game_id = G.game_id
    ) AS platforms,
    (
        SELECT GROUP_CONCAT(GN.nameOfGenres ORDER BY GN.nameOfGenres ASC SEPARATOR ', ')
        FROM GameGenres GG
        JOIN Genres GN ON GG.genre_id = GN.genre_id
        WHERE GG.game_id = G.game_id
    ) AS genres
FROM Games G;

	-- Trigger for BEFORE INSERT
		DELIMITER //
		CREATE TRIGGER before_insert_Games
		BEFORE INSERT ON Games
		FOR EACH ROW
		BEGIN
			-- Check if the released date is more than two years in the future
			IF NEW.released_date > DATE_ADD(CURDATE(), INTERVAL 2 YEAR) THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Invalid released date. Cannot set released date more than two years in the future.';
			END IF;
		END;
		//
		DELIMITER ;

-- Attempt to insert a game with a release date more than two years in the future (SHOULD FAIL) if you run this
-- INSERT INTO Games (nameOfGames, released_date, rating, summary)
-- VALUES ('Future Game', DATE_ADD(CURDATE(), INTERVAL 3 YEAR), 4.5, 'A game from the future');
 
 -- **************************** Query *********************************
 
 -- 1. Basic select with simple where clause
 
	 -- Retrieve games with a rating greater than 80
			SELECT *
			FROM Games
			WHERE rating > 80;

-- 2. Basic select with simple group by clause (with and without having clause)

	--  Retrieve the count of games for each genre:

		-- Basic SELECT with GROUP BY Clause (Without HAVING):
			SELECT G.nameOfGenres AS genre_name, COUNT(*) AS game_count
			FROM GameGenres GG
			JOIN Genres G ON GG.genre_id = G.genre_id
			GROUP BY genre_name;

		-- Basic SELECT with GROUP BY Clause and HAVING Clause:
			SELECT G.nameOfGenres AS genre_name, COUNT(*) AS game_count
			FROM GameGenres GG
			JOIN Genres G ON GG.genre_id = G.genre_id
			GROUP BY genre_name
			HAVING game_count > 5;

-- 3. A simple join select query using cartesian product and where clause vs. a join query using on.

	-- Retrieve all combinations of games and genres where the rating is greater than 50
    
        -- Simple Join using Cartesian Product and WHERE Clause:
			SELECT G.nameOfGames, GN.nameOfGenres , G.rating
			FROM Games G, Genres GN
			WHERE G.rating > 50;
            

        -- Join Query using ON Clause
			SELECT G.nameOfGames, GN.nameOfGenres, G.rating
			FROM Games G
			JOIN Genres GN ON G.rating > 50;

-- 4. A few queries to demonstrate various join types on the same tables: inner vs. outer (left and right) vs. full join. Use of null values in the database to show the differences is required.
	
    -- To test the different joins
    INSERT INTO Games (nameOfGames, released_date, rating, summary) VALUES
		('Game1', '2022-01-01', 85.5, 'Awesome action game'),
		('Game2', '2022-02-15', 75.0, 'Exciting adventure game'),
		('Game3', '2022-03-20', 90.2, 'Strategic war game'),
		('Game4', '2022-04-10', 88.0, 'Action-packed thriller');
	
    
  -- Inner Join
	SELECT AG.game_id, G.nameOfGames , G.summary
	FROM ActionGames AG
	JOIN Games G ON AG.game_id = G.game_id ;

-- Left Outer Join
	SELECT AG.game_id, G.nameOfGames , G.summary
	FROM ActionGames AG
	LEFT JOIN Games G ON AG.game_id = G.game_id;

-- Right Outer Join
	SELECT AG.game_id AS action_game_id, G.nameOfGames, G.summary
	FROM ActionGames AG
	RIGHT JOIN Games G ON AG.game_id = G.game_id;

-- Full Outer Join
	SELECT AG.game_id, G.nameOfGames, G.summary
	FROM ActionGames AG
	LEFT JOIN Games G ON AG.game_id = G.game_id

	UNION

	SELECT AG.game_id, G.nameOfGames, G.summary
	FROM ActionGames AG
	RIGHT JOIN Games G ON AG.game_id = G.game_id;

-- 5. Examples to demonstrate correlated queries.

-- Correlated subquery to find games with rating higher than average
	SELECT G.nameOfGames, G.rating
	FROM Games G
	WHERE G.rating > (SELECT AVG(rating) FROM Games); 

-- Correlated subquery to find games released on the same date
SELECT G1.nameOfGames AS game1, G2.nameOfGames AS game2, G1.released_date
FROM Games G1, Games G2
WHERE G1.game_id < G2.game_id
   AND G1.released_date = G2.released_date;

-- 6. One example per set operations: intersect, union, and difference vs. their equivalences without using set operations.

-- Using Intersect:
(SELECT G1.nameOfGames FROM Games G1) INTERSECT (SELECT G2.nameOfGames FROM Games G2 WHERE G2.rating > 90);

-- Without Using Intersect:
SELECT G1.nameOfGames
FROM Games G1
WHERE G1.rating > 90
  AND EXISTS (
    SELECT 1
    FROM Games G2
    WHERE G2.nameOfGames = G1.nameOfGames
  );

-- Union Example
(SELECT G1.nameOfGames FROM Games G1 WHERE G1.rating > 90)UNION (SELECT G2.nameOfGames FROM Games G2 WHERE G2.rating < 30);

-- Equivalence without using Union
SELECT DISTINCT G1.nameOfGames
FROM Games G1
WHERE G1.rating > 90
   OR G1.nameOfGames IN (
      SELECT G2.nameOfGames
      FROM Games G2
      WHERE G2.rating < 30
   );

-- Difference Example
(SELECT G1.nameOfGames FROM Games G1) EXCEPT (SELECT G2.nameOfGames FROM Games G2 WHERE G2.rating > 90);

-- Equivalence without using Difference
SELECT G1.nameOfGames
FROM Games G1
WHERE G1.rating <= 90
  OR NOT EXISTS (
    SELECT 1
    FROM Games G2
    WHERE G2.nameOfGames = G1.nameOfGames
      AND G2.rating > 90
  );

-- 7.An example of a view that has a hard-coded criteria, by which the content of the view may change upon changing the hard-coded value 
	-- Create a view with a hard-coded criteria
	CREATE VIEW HighRatedGamesView AS
	SELECT *
	FROM Games
	WHERE rating > 90;

-- 8. Two implementations of the division operator using a) a regular nested query using NOT IN and b) a correlated nested query using NOT EXISTS and EXCEPT (See [4]).
	-- a) 
		SELECT *
        FROM Games
        WHERE game_id NOT IN (
            SELECT GG.game_id
            FROM GameGenres GG
            JOIN Genres G ON GG.genre_id = G.genre_id
            WHERE G.nameOfGenres = 'Action'
        );
        

	-- b) a correlated nested query using NOT EXISTS and EXCEPT
		SELECT *
		FROM Games G
		WHERE NOT EXISTS (
			SELECT 1
			FROM GameGenres GG
			JOIN Genres Ge ON GG.genre_id = Ge.genre_id
			WHERE Ge.nameOfGenres = 'Action' AND GG.game_id = G.game_id
		)
		EXCEPT
		SELECT *
		FROM Games
		WHERE game_id IS NULL;



-- 9. Provide queries that demonstrates the overlap and covering constraints. (uncomment to see below results show that the constraints are working).

	-- A) Overlapping Constraint:

	-- Should show that the covering constraint is working for checking the rating remains between 0 and 100 , in this case it should show it cant be inserted
		-- INSERT INTO Games (nameOfGames, released_date, rating, summary)
		-- VALUES ('random', '2005-06-15', 112, 'Action-adventure game based on the movie');
        
		SELECT *
		FROM Games
		WHERE rating < 0 OR rating > 100;



	-- B) Covering Constraint:
    -- Insert a valid record
		-- INSERT INTO GameGenres (game_id, genre_id)
		-- VALUES (1, 101);

		-- Attempt to insert a duplicate record (violating the primary key constraint)
		-- This should result in an error
		-- INSERT INTO GameGenres (game_id, genre_id)
		-- VALUES (1, 101);
	
		SELECT game_id, genre_id, COUNT(*)
		FROM GameGenres
		GROUP BY game_id, genre_id
		HAVING COUNT(*) > 1;

