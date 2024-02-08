import json
import requests

api_key = 'b1534a2c9c1643f8a868f4b87fc0f390'
base_url = 'https://api.rawg.io/api/games'

games_to_search = ['batman', 'superman', 'spiderman', 'call of duty', 'naruto', 'tekken', 'final fantasy',
                   'grand theft auto', 'mortal kombat', 'far cry', 'red dead redemption', 'fallout', 'mafia',
                   'forza', 'skyrim', 'star wars', 'borderlands', 'madden', 'fifa', 'battlefield', 'street fighter',
                   'five nights at freddy\'s', 'halo', 'crash', 'wwe', 'prototype', 'the last of us', 'resident evil']

all_games_data = []

for game_name in games_to_search:
    params = {
        'key': api_key,
        'search': game_name,
    }

    response = requests.get(base_url, params=params)

    if response.status_code == 200:
        data = response.json()

        # Extract relevant information about each game
        if 'results' in data:
            results = data['results']
            for result in results:
                game_info = {
                    'name': result.get('name', None),  # If empty, set to None
                    'platform': ', '.join([platform['platform']['name'] for platform in result.get('platforms', [])]) if result.get('platforms') else None,  # If empty, set to None
                    'released_date': result.get('released', None),  # If empty, set to None
                    'genre': ', '.join([genre['name'] for genre in result.get('genres', [])]) if result.get('genres') else None  # If empty, set to None
                }

                # Append the extracted information to the list
                all_games_data.append(game_info)
        else:
            print(f"No results found for {game_name}")
    else:
        print(f"Error for {game_name}: {response.status_code}, {response.text}")

# Write the list of games and their data to a JSON file
with open('games_data.json', 'w') as json_file:
    json.dump(all_games_data, json_file, indent=2)

print("Data has been successfully stored in games_data.json")

