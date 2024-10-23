#!/bin/bash

# Function to check if jq is installed
check_jq_installed() {
  if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
  else
    echo "jq is already installed."
  fi
}

# Check for jq installation
check_jq_installed

# Load credentials and project name from private.json
if [ ! -f private.json ]; then
  echo "Error: private.json not found!"
  exit 1
fi

# Read credentials and project name from private.json
SOURCEFORGE_USERNAME=$(jq -r '.username' private.json)
SOURCEFORGE_PASSWORD=$(jq -r '.password' private.json)  # You may not need this in the script
PROJECT_NAME=$(jq -r '.project_name' private.json)

# Define the upload path on SourceForge
UPLOAD_PATH="maheshtechncals@frs.sourceforge.net:/home/frs/project/$PROJECT_NAME"

# Check if there are any files in the current directory
FILES=(*)
if [ ${#FILES[@]} -eq 0 ]; then
  echo "No files to upload in the current directory."
  exit 1
fi

# Upload each file in the current directory via SCP
for FILE in "${FILES[@]}"; do
  # Skip the script itself and private.json
  if [[ "$FILE" == "upload_to_sourceforge.sh" || "$FILE" == "private.json" ]]; then
    continue
  fi

  echo "Uploading $FILE to $UPLOAD_PATH..."

  # Use scp to upload the file
  scp "$FILE" "$UPLOAD_PATH"

  # Check if the upload was successful
  if [ $? -eq 0 ]; then
    echo "Successfully uploaded $FILE."
  else
    echo "Failed to upload $FILE."
  fi
done

# Verify uploaded files on SourceForge using SSH
echo "Verifying uploaded files in the project $PROJECT_NAME..."

ssh "$SOURCEFORGE_USERNAME@frs.sourceforge.net" "ls /home/frs/project/$PROJECT_NAME"

echo "Upload and verification process complete."
