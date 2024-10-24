#!/bin/bash

# Function to check if jq is installed
check_dependencies() {
  if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
  else
    echo "jq is already installed."
  fi
}

# Check for dependencies (jq)
check_dependencies

# Load credentials and project name from private.json
if [ ! -f private.json ]; then
  echo "Error: private.json not found!"
  exit 1
fi

# Read credentials and project name from private.json
SOURCEFORGE_USERNAME=$(jq -r '.username' private.json)
PROJECT_NAME=$(jq -r '.project' private.json)

# Ensure that all required fields are present
if [ -z "$SOURCEFORGE_USERNAME" ] || [ -z "$PROJECT_NAME" ]; then
  echo "Error: Missing required fields in private.json!"
  exit 1
fi

# Define the upload path on SourceForge
UPLOAD_PATH="$SOURCEFORGE_USERNAME@frs.sourceforge.net:/home/frs/project/$PROJECT_NAME"

# Find .img and .zip files in the current directory
FILES=$(find . -maxdepth 1 -type f \( -name "*.img" -o -name "*.zip" \))

if [ -z "$FILES" ]; then
  echo "No .img or .zip files found to upload."
  exit 1
fi

# Upload each file in the current directory via SCP
for FILE in $FILES; do
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
