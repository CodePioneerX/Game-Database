# Game Database Management System (GDBMS)

## Overview
- This project focuses on creating a robust Game Database Management System (GDBMS) utilizing data from external APIs, namely RAWG API and IGDB API, to gather comprehensive information about various games. The system processes this data, merges it, and populates a MySQL database, ensuring data integrity and providing simplified views for easy access. Additionally, the project involves transitioning the database design from SQL to NoSQL using Neo4j, streamlining the data transfer process while incorporating design changes based on project requirements.

## Data Processing
- Three Python scripts (Rawg.py, IGDB.py, and main.py) handle data processing tasks, including fetching game data from RAWG API, merging data from both APIs, and inserting it into the MySQL database.
- Rawg.py fetches game data from RAWG API and stores it in a JSON file (games_data.json).
- IGDB.py retrieves additional data from IGDB API, merges it with RAWG data, and stores the merged data in another JSON file (merged_data.json).
- main.py reads the merged data and inserts it into the MySQL database.

## Database Design
- The MySQL database named GAMES encompasses several tables such as Games, ActionGames, Platforms, Genres, GamePlatforms, and GameGenres.
- Views (e.g., ActionGamesView and GameDetailsView) offer different perspectives on the game data.
- Constraints including primary key constraints, foreign key relationships, and custom triggers ensure data integrity.

## Data Transfer and NoSQL Script
- Data transfer from SQL to NoSQL involves running Python scripts (RAWG.py, IGDB.py, and main.py) to fetch, process, and populate the MySQL database.
- The process includes exporting entity tables as CSV files and transferring them to the Neo4j database directory for import.
- Cypher queries provided in the project documentation facilitate the import process into Neo4j.

