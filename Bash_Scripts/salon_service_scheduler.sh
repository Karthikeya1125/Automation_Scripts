#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# Display services before input
SERVICES=$($PSQL "SELECT service_id, name FROM services;")
echo "$SERVICES" | while IFS='|' read SERVICE_ID NAME
do
  echo "$SERVICE_ID) $NAME"
done

# Prompt for a valid service selection
while true; do
  read SERVICE_ID_SELECTED
  SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  
  if [[ -n $SERVICE_EXISTS ]]; then
    break
  else
    echo -e "\nI could not find that service. Please choose a valid service:\n"
    
    # Redisplay services
    SERVICES=$($PSQL "SELECT service_id, name FROM services;")
    echo "$SERVICES" | while IFS='|' read SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi
done

# Ask for phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_NAME ]]; 
then
  echo -e "\nI don't have a record for that phone number. What's your name?"
  read CUSTOMER_NAME

  # Insert new customer
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
fi

# Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

# Ask for appointment time
echo -e "\nWhat time would you like your appointment, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

echo -e "\nI have put you down for a $(echo $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;") | tr -d '\n') at $SERVICE_TIME, $CUSTOMER_NAME."
