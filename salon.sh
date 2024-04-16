#! /bin/bash

echo -e "\nWelcome to the Salon"

echo -e "\nServices:\n"

PSQL="psql --username=freecodecamp --dbname=salon -t --tuples-only -c"

SERVICES_MENU(){
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read ID BAR NAME BAR PRICE
  do
    echo "$ID) $NAME"
  done

  # Request a choice
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ [1-5] ]]
  then
    echo -e "\nInvalid choice"
    SERVICES_MENU
  else
    # Ask for phone number
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    # Get customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    # If not found
    if [[ -z $CUSTOMER_ID ]]
    then
      # Get name
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      # Add to DB
      INSERT_CUST_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
      echo $INSERT_RESULT
      # Get customer ID
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ *//')
    fi

    echo -e "\nSelect a time"
    read SERVICE_TIME
    # Get service name
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    FMT_SERVICE=$(echo $SERVICE | sed 's/ *//')
    # Create appointment
    INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    echo -e "\nI have put you down for a $FMT_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

SERVICES_MENU