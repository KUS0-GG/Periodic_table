#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"
DIGITS="^[0-9]+$"

# ask user to search for an element
if [[ -z $1 ]]
  then
    echo "Please provide an element as an argument."
  else
    #check for number
    if ! [[ $1 =~ $DIGITS ]] 
    then
      #get atomic_number from name or symbol
      AN=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1'")

    else
      # get atomic_number from number
      AN=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")

    fi

    if [[ -z $AN ]]
    then
      echo -e "I could not find that element in the database."
    else
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$AN")
      S=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$AN")
      TYPE=$($PSQL "SELECT type FROM properties FULL JOIN types USING(type_id) WHERE atomic_number=$AN")
      AM=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$AN")
      MP=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$AN")
      BP=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$AN")
      echo "The element with atomic number $AN is $NAME (${S/ /}). It's a $TYPE, with a mass of $AM amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius." | tr -s " "
  
    fi
fi    
