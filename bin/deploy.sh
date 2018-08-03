# Check to require a username to be [given as argument][1]
#
# [1]: https://stackoverflow.com/questions/6482377/check-existence-of-input-argument-in-a-bash-shell-script
if [ -z "$1" ]; then
    echo ERROR: Username argument required!

    # [terminate and indicate error][3]
    #
    # [3]: https://stackoverflow.com/questions/4381618/exit-a-script-on-error
    exit 1
fi

MDAPI_OUTPUT_DIR=.mdapi/out

# Delete the converted metadata output directory [if it exists][2]
#
# [2]: https://stackoverflow.com/questions/59838/check-if-a-directory-exists-in-a-shell-script
if [ -d "$MDAPI_OUTPUT_DIR" ]; then
    echo found: $MDAPI_OUTPUT_DIR
    rm -Rv $MDAPI_OUTPUT_DIR
    echo deleted
else
    echo NOT found: $MDAPI_OUTPUT_DIR
fi

mkdir -p $MDAPI_OUTPUT_DIR

# Convert the source and deploy
sfdx force:source:convert -d mdapi_output
sfdx force:mdapi:deploy -d mdapi_output -w 5 -u "$1" \
        -l "RunLocalTests"