#!/bin/bash

# Variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random integer number in range <1;1000>
NUMBER_GENERATED=$((RANDOM % 1000 + 1))

# Prompt user for username
echo -e "Enter your username: "
read USERNAME

# Get user_id from database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USERNAME'")

# Check if user is already in database
if [[ -n $USER_ID ]]; then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users_informations WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users_informations WHERE user_id=$USER_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert username into database
  INSERT_USERNAME=$($PSQL "INSERT INTO users(user_name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USERNAME'")

  # Insert initial information into users_informations
  INSERT_INFO=$($PSQL "INSERT INTO users_informations(user_id, games_played, best_game) VALUES($USER_ID, 0, 1000)")
  GAMES_PLAYED=0
  BEST_GAME=1000
fi

# Start of the guessing game
echo -e "Guess the secret number between 1 and 1000:"
read USER_GUESS

counter=1

while true; do
  # If user input is not a Integer
  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    
    # Check whether user guessed the number
    if [[ $USER_GUESS -eq $NUMBER_GENERATED ]]; then
      echo -e "You guessed it in $counter tries. The secret number was $NUMBER_GENERATED. Nice job!"
      
      # Update games_played
      G_P=$($PSQL "UPDATE users_informations SET games_played = games_played + 1 WHERE user_id = $USER_ID")

      # Update best_game if the current guess count is better
      if [[ $counter -lt $BEST_GAME ]]; then
        B_G=$($PSQL "UPDATE users_informations SET best_game = $counter WHERE user_id = $USER_ID")
      fi

      break

    # If user input was greater than generated number
    elif [[ $USER_GUESS -gt $NUMBER_GENERATED ]]; then
      echo -e "\nIt's lower than that, guess again:"
      read USER_GUESS
      ((counter++))

    # If user input was smaller than generated number
    else
      echo -e "\nIt's higher than that, guess again:"
      read USER_GUESS
      ((counter++))
    fi
  else
    echo "That is not an integer, guess again:"
    read USER_GUESS
  fi
done
