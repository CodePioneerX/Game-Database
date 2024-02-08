import mysql.connector
import json

# Replace these with your own database connection details
database_config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'Default',
    'database': 'GAMES'
}

# Function to read JSON file and insert entries into MySQL database
def insert_json_to_mysql(json_file_path):
    # Connect to the MySQL database
    connection = mysql.connector.connect(**database_config)
    cursor = connection.cursor()

    try:
        # Read JSON file
        with open(json_file_path, 'r') as file:
            json_data = json.load(file)

        # Iterate through JSON entries and insert into MySQL
        for entry in json_data:
            # Set 'null' or empty strings to None
            entry = {key: None if value == 'null' or value == '' else value for key, value in entry.items()}

            # Insert into Games table
            game_query = "INSERT INTO Games (nameOfGames, released_date, rating, summary) VALUES (%s, %s, %s, %s)"
            game_values = (
                entry.get('name'),
                entry.get('released_date'),
                entry.get('rating'),
                entry.get('summary')
            )
            cursor.execute(game_query, game_values)

            # Get the game_id of the inserted game
            game_id = cursor.lastrowid

            # Insert into Genres table
            genres = entry.get('genre', '').split(', ') if entry.get('genre') else [None]
            for genre_name in genres:
                # Insert NULL if genre_name is None
                genre_name = genre_name if genre_name else None

                genre_query = "INSERT INTO Genres (nameOfGenres) VALUES (%s)"
                genre_values = (genre_name,)
                cursor.execute(genre_query, genre_values)

                # Get the genre_id of the inserted genre
                genre_id = cursor.lastrowid

                # Insert into GameGenres table
                game_genres_query = "INSERT INTO GameGenres (game_id, genre_id) VALUES (%s, %s)"
                game_genres_values = (game_id, genre_id)
                cursor.execute(game_genres_query, game_genres_values)

                # Insert into ActionGames table if the genre is "Action"
                if genre_name == 'Action':
                    action_games_query = "INSERT INTO ActionGames (game_id) VALUES (%s)"
                    action_games_values = (game_id,)
                    cursor.execute(action_games_query, action_games_values)

            # Commit changes after processing genres for the current game
            connection.commit()

            # Insert into Platforms table
            platform = entry.get('platform')
            if platform is not None:  # Explicitly check for None

                # Check if the platform already exists
                cursor.execute("SELECT platform_id FROM Platforms WHERE nameOfPlatform = %s", (platform,))
                result = cursor.fetchone()

                if result:
                    platform_id = result[0]
                else:
                    # Insert into Platforms table if it doesn't exist
                    cursor.execute("INSERT INTO Platforms (nameOfPlatform) VALUES (%s)", (platform,))
                    platform_id = cursor.lastrowid

                # Insert into GamePlatforms table
                game_platforms_query = "INSERT INTO GamePlatforms (game_id, platform_id) VALUES (%s, %s)"
                game_platforms_values = (game_id, platform_id)
                cursor.execute(game_platforms_query, game_platforms_values)

                # Commit changes after processing the platform for the current game
                connection.commit()
            else:
                # Insert a row with NULL value in Platforms table
                cursor.execute("INSERT INTO Platforms (nameOfPlatform) VALUES (NULL)")
                platform_id = cursor.lastrowid

                # Insert into GamePlatforms table
                game_platforms_query = "INSERT INTO GamePlatforms (game_id, platform_id) VALUES (%s, %s)"
                game_platforms_values = (game_id, platform_id)
                cursor.execute(game_platforms_query, game_platforms_values)

                # Commit changes after processing the platform for the current game
                connection.commit()

            print("Data inserted successfully!")

    except Exception as e:
        print(f"Error: {e}")

    finally:
        # Close the cursor and connection
        cursor.close()
        connection.close()

# Replace 'merged_data.json' with the path to your JSON file
insert_json_to_mysql('merged_data.json')
