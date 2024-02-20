# TODO: refactor to match the create-sponsored-merchant script styling
# TODO: Add attribution 

#!/bin/bash

ACTION="${1-help}"
ENV="${2-6}"
TYPE="${3-consumer}"

help () { printf '
    |---------------------------------------------------------------------------------
    | HELP MENU:
    | unit --> run pytest unit tests (note), need to be in the beele directory
    | gen-email -> generate an email address using mailtrap
    |---------------------------------------------------------------------------------
    '
}
#######
MAILTRAP_CODE='EMPTY'

function get_mailtrap_code
{
    case $ENV in
        '3')
            echo 'Setting mailtrap email code for QA3'
            MAILTRAP_CODE='7fba35ac3e-c8e12c'
            ;;
        '6')
            echo 'Setting mailtrap email code for QA6'
            MAILTRAP_CODE='f5652bc82a-fa4bd9'
            ;;
    esac
}

case $ACTION in
    'unit')
        echo 'unit tests'
        export TESTFILES=$(find source/** -type f -name 'test_*.py')
        echo "Running the following tests: ${TESTFILES}"
        pipenv run pytest --junitxml=unit-test-results/junit.xml ${TESTFILES}
        ;;

    'gen-email')
        echo 'Generating an email address for QA'$ENV
        echo ''
        get_mailtrap_code
        MAIL=$MAILTRAP_CODE'+skirvin-'$TYPE'-'$(date +%s)'@inbox.mailtrap.io'
        echo $MAIL
        echo $MAIL | pbcopy
        ;;

    *)
        echo "Unkonwn Input Type: $ACTION"
        help;;
esac