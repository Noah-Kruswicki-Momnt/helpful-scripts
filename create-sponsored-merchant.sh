#!/bin/bash
auth=$SPONSOR_AUTH
contractor_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
email_uuid=$(uuidgen | tr -d '-' | cut -c 1-8 | tr '[:upper:]' '[:lower:]')
environment=qa4.qa.
user_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
ticket_number=""
sponsor_baseurl=""
sponsor_redirect=""

function usage {
  echo "Usage: $0 [-t <ticket_number>] [-s <sponsor>] [-e <environment>] [-a <authorization>]"
  echo "    -t <ticket_number>: Specify the ticket number under test (optional)"
  echo "    -s <sponsor>: Specify the sponsor name in lowercase (acron or paradigm)"
  echo "    -e <environment>: Specify the environment to create the sponsor on (ex: qa4.qa.)"
  echo "    -a <authorization>: Specify the basic authorization string used to create the sponsored merchant" 
  echo " "
  echo "Example : SPONSOR_AUTH=<insert-auth-token> sh ./create-sponsored-merchant.sh -e qa4.qa. -s acorn -t me-618"
  exit 1
}

while getopts "t:s:e:a:" opt; do
        case ${opt} in
        t) ticket_number=$OPTARG;;
        s) sponsor=$OPTARG;;
        e) environment=$OPTARG;;
        a) auth=$OPTARG;;
        \?) usage;;
        :) echo "Option -$OPTARG requires an argument" >&2;;
        esac
    done

createSponsoredMerchant () {
    # Verify required data
    if [ -z $sponsor ]
    then
        echo "ERROR: No sponsor was provided and no default value has been set"
        usage
        exit
    fi

    if [ -z $auth ]
    then
        echo "ERROR: Basic auth is required. No value was found at the environement variable SPONSOR_AUTH and no auth was passed in."
        usage
        exit
    fi

    # Generate sponsor urls
    if [ "$sponsor" = "acorn" ]; then
        acorn_baseurl=https://"$environment"getacornfinance.com
        acorn_redirect=https://my.acornfinance.com/sign-in
        sponsor_baseurl=$acorn_baseurl
        sponsor_redirect=$acorn_redirect
    elif [ "$sponsor" = "paradigm" ]; then
        paradigm_baseurl=https://"$environment"myparadigmfinance.com
        paradigm_redirect=https://paradigmvendo.com/login
        sponsor_baseurl=$paradigm_baseurl
        sponsor_redirect=$paradigm_redirect
    fi 

    # Construct the JSON data string
    json_data='{
        "user_business_email": "18362f17c3-596b79+'"$ticket_number-$(whoami)-$email_uuid"'@inbox.mailtrap.io",
        "business_name": "24 Hour",
        "first_name": "Nicholas",
        "middle_name": "Kamal",
        "last_name": "Anderson",
        "mobile_phone": "+15416669999",
        "user_id": "'"$user_id"'",
        "business_address_1": "431 E 165TH ST",
        "business_address_2": "C",
        "business_phone": "+17067446389",
        "state": "NY",
        "zip_code": "10456",
        "city": "Bronx",
        "contractor_id": "'"$contractor_id"'",
        "sponsor_callback_url": "https://webhook.site/80ac1cf2-e568-4a17-9ea3-231281c6329e",
        "sponsor_redirect_url": "'"$sponsor_redirect"'"
    }'

    # Print payload
    echo "\033[34m Sending the follwing data to \033[31m$sponsor_baseurl/api/v1/sponsor/merchants/onboarding/\033[34m: \n $json_data \033[0m"

    # Make API call
    curl --location --request POST "$sponsor_baseurl/api/v1/sponsor/merchants/onboarding/" \
    --header "Content-Type: application/json" \
    --header "Authorization: Basic $auth" \
    --data-raw "$json_data"

    # TODO: Add error handling
}

createSponsoredMerchant
