#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\n ~~~~~ WELCOME TO THE GUESSING GAME ~~~~~ \n"

echo -e "Enter your username:"
read NAME
USERNAME=$($PSQL "SELECT name FROM users WHERE name = '$NAME'")
if [[ -z $USERNAME ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES ('$NAME')")
  echo -e "\nWelcome, $NAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games JOIN users USING(user_id) WHERE name='$NAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games JOIN users USING(user_id) WHERE name='$NAME'")
  echo -e "\nWelcome back, $(echo $USERNAME | sed -E 's/^ *| *$//g')! You have played $(echo $GAMES_PLAYED | sed -E 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -E 's/^ *| *$//g') guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
RANDOM_NUMBER=$(expr $RANDOM % 1000)
GUESS=-1
COUNT=0
while [ $GUESS -ne $RANDOM_NUMBER ]
do
  read GUESS
  COUNT=$(expr $COUNT + 1 )
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done
  if [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    if [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
  fi
done

echo -e "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")
INSERT_USER=$($PSQL "INSERT INTO games(guesses, user_id) VALUES ('$COUNT', '$USER_ID')")
