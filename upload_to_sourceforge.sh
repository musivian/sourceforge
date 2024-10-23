#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to check if jq, sshpass, and pv are installed
check_dependencies() {
  echo -e "${CYAN}Checking dependencies...${NC}"
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

  if ! command -v pv &> /dev/null; then
    echo -e "${YELLOW}pv is not installed. Installing pv...${NC}"
    sudo apt-get install -y pv
  else
    echo -e "${GREEN}pv is already installed.${NC}"
  fi
}

# Check for dependencies (jq, sshpass, and pv)
check_dependencies

# Load credentials and project name from private.json
if [ ! -f private.json ]; then
  echo -e "${RED}Error: private.json not found!${NC}"
  exit 1
fi

echo -e "${CYAN}Loading credentials from private.json...${NC}"
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

  echo -e "${BLUE}Uploading $FILE to $UPLOAD_PATH...${NC}"

  # Get the file size
  FILE_SIZE=$(stat --printf="%s" "$FILE")

  # Use sshpass with scp and pv to upload the file with a progress bar
  sshpass -p "$SOURCEFORGE_PASSWORD" pv -p -t -e -r -s "$FILE_SIZE" "$FILE" | sshpass -p "$SOURCEFORGE_PASSWORD" scp -o StrictHostKeyChecking=no /dev/stdin "$UPLOAD_PATH/$FILE"

  # Check if the upload was successful
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully uploaded $FILE.${NC}"
  else
    echo -e "${RED}Failed to upload $FILE.${NC}"
  fi
done

# Verify uploaded files on SourceForge using sshpass with ssh
echo -e "${CYAN}Verifying uploaded files in the project $PROJECT_NAME...${NC}"

sshpass -p "$SOURCEFORGE_PASSWORD" ssh -o StrictHostKeyChecking=no "$SOURCEFORGE_USERNAME@frs.sourceforge.net" "ls /home/frs/project/$PROJECT_NAME"

echo -e "${GREEN}Upload and verification process complete.${NC}"
