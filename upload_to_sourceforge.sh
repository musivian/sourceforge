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
SOURCEFORGE_PASSWORD=$(jq -r '.password' private.json)
PROJECT_NAME=$(jq -r '.project_name' private.json)

# Check if there are any files in the current directory
FILES=(*)
if [ ${#FILES[@]} -eq 0 ]; then
  echo "No files to upload in the current directory."
  exit 1
fi

# Set the API endpoint for uploading files
API_URL="https://sourceforge.net/projects/$PROJECT_NAME/files/upload/"

# Upload each file in the current directory
for FILE in "${FILES[@]}"; do
  # Skip the script itself and private.json
  if [[ "$FILE" == "upload_to_sourceforge.sh" || "$FILE" == "private.json" ]]; then
    continue
  fi

  echo "Uploading $FILE..."

  # Use curl to upload the file
  response=$(curl -s -u "$SOURCEFORGE_USERNAME:$SOURCEFORGE_PASSWORD" -T "$FILE" "$API_URL$FILE")

  # Output the raw response for debugging
  echo "Response from SourceForge for $FILE: $response"

  # Check for success or failure
  if [[ "$response" == *"success"* ]]; then
    echo "Successfully uploaded $FILE."
  else
    echo "Failed to upload $FILE. Check the response above for more details."
  fi
done

# Verify uploaded files
echo "Verifying uploaded files in the project $PROJECT_NAME..."

# Set the API endpoint to list files in the project
LIST_API_URL="https://sourceforge.net/projects/$PROJECT_NAME/files/"
# Use curl to get the list of files
file_list=$(curl -s "$LIST_API_URL" | grep -oP '(?<=href=")[^"]*' | grep "$PROJECT_NAME")

if [ -z "$file_list" ]; then
  echo "No files found in the project $PROJECT_NAME."
else
  echo "Files in the project $PROJECT_NAME:"
  echo "$file_list"
fi

echo "All uploads and verifications are complete."
