# Define the Metadata API input directory
MDAPI_INPUT_DIR=.mdapi/in

# Define the Salesforce DX source directory
SFDX_SOURCE_DIR=force-app

# Delete the existing directory... if it exists
if [ -d "$MDAPI_INPUT_DIR" ]; then
    echo found: $MDAPI_INPUT_DIR
    rm -Rv "$MDAPI_INPUT_DIR"
    echo deleted
    mkdir -p "$MDAPI_INPUT_DIR"
fi

# Require a username argument followed by a change set argument
if [ -z "$1" ]; then
    echo ERROR: Username argument required!

    # [terminate and indicate error][3]
    #
    # [3]: https://stackoverflow.com/questions/4381618/exit-a-script-on-error
    exit 1
fi

if [ -z "$2" ]; then
    echo ERROR: Change set name argument required!

    # [terminate and indicate error][3]
    #
    # [3]: https://stackoverflow.com/questions/4381618/exit-a-script-on-error
    exit 1
fi

# Retrieve the change set metadata
sfdx force:mdapi:retrieve -r "$MDAPI_INPUT_DIR" \
        -u $1 -p "$2"

# Extract the metadata contents
unzip "$MDAPI_INPUT_DIR/unpackaged.zip" -d "$MDAPI_INPUT_DIR"

# Convert the Metadata API source into Salesforce DX source
sfdx force:mdapi:convert \
        -r "$MDAPI_INPUT_DIR/$2" \
        -d "$SFDX_SOURCE_DIR"