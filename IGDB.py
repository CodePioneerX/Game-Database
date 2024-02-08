import json
import requests

def get_igdb_data(api_key, access_token, game_name):
    igdb_api_url = 'https://api.igdb.com/v4/games'

    headers = {
        'Authorization': f'Bearer {access_token}',
        'Client-ID': api_key,
        'Content-Type': 'application/json',
    }

    # Define the game fields you want to retrieve (excluding age_ratings)
    fields = 'rating,summary'

    # Set up the query parameters
    params = {
        'search': game_name,
        'fields': fields,
    }

    # Make the request to the IGDB API
    try:
        response = requests.get(igdb_api_url, headers=headers, params=params)
        response.raise_for_status()  # Raise an HTTPError for bad responses

        if response.status_code == 200:
            data = response.json()
            return data
        else:
            print(f"Error for {game_name} in IGDB: {response.status_code}, {response.text}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Request error for {game_name} in IGDB: {e}")
        return None

# Load the data obtained from the RAWG API
with open('games_data.json', 'r') as json_file:
    rawg_data = json.load(json_file)

# Initialize a list to store IGDB data for each game
igdb_data_list = []

# API keys for IGDB
igdb_api_key = 'ws3sl99b8uqg28g382tkg0rgkvji3p'
igdb_access_token = '7kdr3ujp0t65hm7au6tolgz9pdlmhd'

# Iterate through the games obtained from RAWG and fetch data from IGDB
for game in rawg_data:
    game_name = game['name']
    igdb_data = get_igdb_data(igdb_api_key, igdb_access_token, game_name)

    if igdb_data:
        # Extract relevant information from IGDB data (excluding age_ratings)
        igdb_info = {
            'rating': igdb_data[0].get('rating', None),  # If empty, set to None
            'summary': igdb_data[0].get('summary', None),  # If empty, set to None
        }

        # Merge data from RAWG and IGDB
        merged_data = {**game, **igdb_info}
        igdb_data_list.append(merged_data)

# Write the merged data to a JSON file
with open('merged_data.json', 'w') as json_file:
    json.dump(igdb_data_list, json_file, indent=2)

print("Merged data has been successfully stored in merged_data.json")
