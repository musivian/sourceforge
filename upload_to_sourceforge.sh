#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Function to check if jq and sshpass are installed
check_dependencies() {
  echo -e "${BLUE}Checking dependencies...${NC}"

  if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}jq is not installed. Installing jq...${NC}"
    sudo apt-get update
    sudo apt-get install -y jq
  else
    echo -e "${GREEN}jq is already installed.${NC}"
  fi

  if ! command -v sshpass &> /dev/null; then
    echo -e "${YELLOW}sshpass is not installed. Installing sshpass...${NC}"
    sudo apt-get install -y sshpass
  else
    echo -e "${GREEN}sshpass is already installed.${NC}"
  fi
}

# Check for dependencies (jq and sshpass)
check_dependencies

# Load credentials and project name from private.json
if [ ! -f private.json ]; then
  echo -e "${RED}Error: private.json not found!${NC}"
  exit 1
fi

# Read credentials and project name from private.json
SOURCEFORGE_USERNAME=$(jq -r '.username' private.json)
SOURCEFORGE_PASSWORD=$(jq -r '.password' private.json)
PROJECT_NAME=$(jq -r '.project_name' private.json)

# Define the upload path on SourceForge
UPLOAD_PATH="maheshtechncals@frs.sourceforge.net:/home/frs/project/$PROJECT_NAME"

# Check if there are any files in the current directory
FILES=(*)
if [ ${#FILES[@]} -eq 0 ]; then
  echo -e "${RED}No files to upload in the current directory.${NC}"
  exit 1
fi

# Upload each file in the current directory via SCP using sshpass and show progress
for FILE in "${FILES[@]}"; do
  # Skip the script itself and private.json
  if [[ "$FILE" == "upload_to_sourceforge.sh" || "$FILE" == "private.json" ]]; then
    continue
  fi

  echo -e "${BLUE}Uploading ${YELLOW}$FILE${BLUE} to ${YELLOW}$UPLOAD_PATH${BLUE}...${NC}"

  # Use sshpass with scp to upload the file, show progress, and automatically accept SSH key fingerprints
  sshpass -p "$SOURCEFORGE_PASSWORD" scp -v -o StrictHostKeyChecking=no "$FILE" "$UPLOAD_PATH"

  # Check if the upload was successful
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully uploaded $FILE.${NC}"
  else
    echo -e "${RED}Failed to upload $FILE.${NC}"
  fi
done

echo -e "${GREEN}All files have been uploaded successfully.${NC}"
