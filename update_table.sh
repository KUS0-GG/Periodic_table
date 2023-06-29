#!/bin/bash
# program to update the issues with PSQL when system resets

PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# properties table: Rename weight to atomic_mass
WEIGHT=$($PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass")
if [[ $WEIGHT == "ALTER TABLE" ]]
  then 
    echo Weight updated
  else
    echo FAILED TO UPDATE WEIGHT
fi

# properties table :Rename melting_point and boiling_point to ..._celsius
MELTING=$($PSQL "ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius")
if [[ $MELTING == "ALTER TABLE" ]]
  then 
    echo melting updated
  else
    echo FAILED TO UPDATE MELTING
fi
BOILING=$($PSQL "ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius")
if [[ $BOILING == "ALTER TABLE" ]]
  then 
    echo boiling updated
  else
    echo FAILED TO UPDATE BOILING
fi

# properties table: Both above make NOT NULL
MELTING_NULL=$($PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL")
if [[ $MELTING_NULL == "ALTER TABLE" ]]
  then 
    echo melting NULL updated
  else
    echo FAILED TO UPDATE MELTING NULL
fi
BOILING_NULL=$($PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL")
if [[ $BOILING_NULL == "ALTER TABLE" ]]
  then 
    echo boiling NULL updated
  else
    echo FAILED TO UPDATE BOILING NULL
fi

# elements table: make symbol and name columns UNIQUE
SYMBOL=$($PSQL "ALTER TABLE elements ADD UNIQUE(symbol)")
if [[ $SYMBOL == "ALTER TABLE" ]]
  then 
    echo symbol UNIQUE updated
  else
    echo FAILED TO UPDATE symbol UNIQUE
fi
NAME=$($PSQL "ALTER TABLE elements ADD UNIQUE(name)")
if [[ $NAME == "ALTER TABLE" ]]
  then 
    echo name UNIQUE updated
  else
    echo FAILED TO UPDATE name UNIQUE
fi

# elements table: make symbol and name columns NOT NULL
SYMBOL_NULL=$($PSQL "ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL")
if [[ $SYMBOL_NULL == "ALTER TABLE" ]]
  then 
    echo SYMBOL NULL updated
  else
    echo FAILED TO UPDATE SYMBOL NULL
fi
NAME_NULL=$($PSQL "ALTER TABLE elements ALTER COLUMN name SET NOT NULL")
if [[ $NAME_NULL == "ALTER TABLE" ]]
  then 
    echo name NULL updated
  else
    echo FAILED TO UPDATE NAME NULL
fi

# create types table w id SERIAL PK and type VARCHAR NOT NULL
TYPES=$($PSQL "CREATE TABLE types(type_id SERIAL PRIMARY KEY, type VARCHAR(30) NOT NULL)")
if [[ $TYPES == "CREATE TABLE" ]]
  then 
    echo TYPES table created
  else
    echo FAILED TO create types table
fi
  
# add rows to types table metal metalloid nonmetal
INSERT_TYPES=$($PSQL "INSERT INTO types(type) VALUES('metal'),('metalloid'),('nonmetal')")
if [[ $TYPES == "INSERT 0 3" ]]
  then 
    echo types inserted
  else
    echo FAILED TO create types table
fi

# insert type_id column to properties table
ADD_TYPE_ID=$($PSQL "ALTER TABLE properties ADD COLUMN type_id INT")
if [[ $ADD_TYPE_ID == "ALTER TABLE" ]]
  then 
    echo ADD_TYPE_ID column added
  else
    echo FAILED TO ADD ADD_TYPE_ID column
fi

# Add missing elements into properties
INSERT_ELEMENTS_P=$($PSQL "INSERT INTO properties(atomic_number,type,atomic_mass,melting_point_celsius,boiling_point_celsius) VALUES(9,'nonmetal',18.998,-220,-188.1),(10,'nonmetal',20.18,-248.6,-246.1)")
if [[ $INSERT_ELEMENTS_P == "INSERT 0 2" ]]
  then 
    echo F and Ne inserted to properties
  else
    echo FAILED TO insert F and Ne to properties
fi

# Add missing elements into elements
INSERT_ELEMENTS=$($PSQL "INSERT INTO elements(atomic_number,symbol,name) VALUES(9,'F','Fluorine'),(10,'Ne','Neon')")
if [[ $INSERT_ELEMENTS == "INSERT 0 2" ]]
  then 
    echo F and Ne inserted to elements
  else
    echo FAILED TO insert F and Ne to elements
fi

# Remove extra element
DELETE_ELEMENT=$($PSQL "DELETE FROM elements WHERE symbol = 'mT'")
if [[ $DELETE_ELEMENT == "DELETE 1" ]]
  then 
    echo Removed mT from elements
  else
    echo FAILED TO remove mT from elements
fi
DELETE_ELEMENT_P=$($PSQL "DELETE FROM properties WHERE atomic_number = 1000")
if [[ $DELETE_ELEMENT_P == "DELETE 1" ]]
  then 
    echo Removed mT from properties
  else
    echo FAILED TO remove mT from properties
fi

# Create list of elements in txt file FIX SPACING ISSUES WHEN PRINTING
echo "$($PSQL "SELECT atomic_number, type FROM properties")" > elements.txt

# update element type_id from elements in txt file
cat elements.txt | while read ATOMIC_NUMBER BAR TYPE
do
  # get type_id
  TYPE_ID=$($PSQL "SELECT type_id FROM types WHERE type='$TYPE'")

  # assign type_id to properties
  ADD_TYPE_ID=$($PSQL "UPDATE properties SET type_id=$TYPE_ID WHERE atomic_number=$ATOMIC_NUMBER")
  if [[ $ADD_TYPE_ID == 'UPDATE 1' ]]
  then
    echo "Atomic number $ATOMIC_NUMBER was updated to a $TYPE"
  else
    echo "Something went wrong with atomic_number $ATOMIC_NUMBER"
  fi
done

# capitalize he and li (2 & 3) first letter
CAPS_H=$($PSQL "UPDATE elements SET symbol = 'He' WHERE atomic_number = 2")
if [[ $CAPS_H == "UPDATE 1" ]]
  then
    echo He updated
  else
    echo he not found
fi

CAPS_L=$($PSQL "UPDATE elements SET symbol = 'Li' WHERE atomic_number = 3")
if [[ $CAPS_L == "UPDATE 1" ]]
  then
    echo Li updated
  else
    echo li not found
fi

# make type_id NOT NULL in properties
TYPE_ID_NULL=$($PSQL "ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL")
if [[ $TYPE_ID_NULL == "ALTER TABLE" ]]
  then
    echo type_id has been set to NOT NULL
  else
    echo FAILED TO SET type_id TO NOT NULL
fi

# set atomic_number(properties) as foreign key (elements)
ATOMIC_NUMBER_FK=$($PSQL "ALTER TABLE properties ADD FOREIGN KEY(atomic_number) REFERENCES elements(atomic_number)")
if [[ $ATOMIC_NUMBER_FK == 'ALTER TABLE' ]]
  then
    echo Atomic number set as foreign key
  else
    echo ATOMIC NUMBER NOT SET AS FOREIGN KEY
fi

# set type_id as a foreign key
TYPE_ID_FK=$($PSQL "ALTER TABLE properties ADD FOREIGN KEY(type_id) REFERENCES types(type_id)")
if [[ $TYPE_ID_FK == 'ALTER TABLE' ]]
  then
    echo Type_id set as foreign key
  else
    echo TYPE_ID NOT SET AS FOREIGN KEY
fi

# change data_type for atomic_mass to decimal
DATA_TYPE=$($PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL")
if [[ $DATA_TYPE == "ALTER TABLE" ]]
  then 
    echo atomic_mass data type updated
  else
    echo FAILED TO UPDATE atomic_mass data type
fi

# update atomic mass from txt
cat atomic_mass.txt | while read ATOMIC_NUMBER BAR ATOMIC_MASS
do
  if [[ $ATOMIC_NUMBER != 'atomic_number' ]]
  then
    UPDATE_MASS=$($PSQL "UPDATE properties SET atomic_mass = '$ATOMIC_MASS' WHERE atomic_number = '$ATOMIC_NUMBER' ")
    if [[ $UPDATE_MASS == "UPDATE 1" ]]
    then
      echo atomic number $ATOMIC_NUMBER has been updated to $ATOMIC_MASS
    fi
  fi
done

# LAST remove type column from properties
NO_TYPE=$($PSQL "ALTER TABLE properties DROP COLUMN type")
if [[ $NO_TYPE == 'ALTER TABLE' ]]
  then
    echo Type column removed from properties
  else
    echo TYPE COLUMN NOT REMOVED 
fi
