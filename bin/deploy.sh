UNPACKAGED_DIR=.sfdx/unpackaged

# You can create a new file config/bash.conf which holds the following content.
# 
#     DEFAULT_USERNAME=slashclock-mc
#
# This will set the default username for this script
LOCAL_CONF=config/bash.conf
if [ -f "$LOCAL_CONF" ]; then
    source "$LOCAL_CONF"
fi

# Prompt for the username
while [ -z "$SFDX_USERNAME" ]
do
    read -p "To where shall we deploy${DEFAULT_USERNAME:+ ($DEFAULT_USERNAME)}? " SFDX_USERNAME
    SFDX_USERNAME="${SFDX_USERNAME:-$DEFAULT_USERNAME}"
done

# Print a few useful pieces of information
echo "Username: $SFDX_USERNAME"

# Delete the existing deployment metadata directory if it exists
if [ -d "$UNPACKAGED_DIR" ]; then
    echo "Found: $UNPACKAGED_DIR"
    echo "Deleting..."
    rm -R "$UNPACKAGED_DIR" || exit 1
fi

# Convert the source
sfdx force:source:convert -d $UNPACKAGED_DIR || exit 1

# Deploy the metadata
time sfdx force:mdapi:deploy -u $SFDX_USERNAME \
    -d $UNPACKAGED_DIR \
    -w 5 || exit 1
