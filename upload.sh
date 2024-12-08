#!/bin/bash

# Display the script author and version
echo -e "\e[1;35m###############################################\e[0m"
echo -e "\e[1;36mScript by Mahesh Technicals - Version 1.3\e[0m"
echo -e "\e[1;35m###############################################\e[0m"

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

# Function to handle script interruption (CTRL+C)
handle_interrupt() {
  echo -e "\n\e[31mScript interrupted! Closing SSH session...\e[0m"
  end_ssh_session
  exit 1
}

# Start SSH ControlMaster session
start_ssh_session() {
  SOCKET=$(mktemp -u)
  ssh -o ControlMaster=yes -o ControlPath="$SOCKET" -fN "$SOURCEFORGE_USERNAME@frs.sourceforge.net"
}

# End SSH ControlMaster session
end_ssh_session() {
  ssh -o ControlPath="$SOCKET" -O exit "$SOURCEFORGE_USERNAME@frs.sourceforge.net"
}

# Trap the SIGINT (CTRL+C) signal and call handle_interrupt function
trap handle_interrupt SIGINT

# Check for dependencies
check_dependencies

# Load credentials and project name from private.json
if [ ! -f private.json ]; then
  echo -e "\e[31mError: private.json not found!\e[0m"
  exit 1
fi

# Read credentials and project name from private.json
SOURCEFORGE_USERNAME=$(jq -r '.username' private.json)
PROJECT_NAME=$(jq -r '.project' private.json)

# Ensure all required fields are present
if [ -z "$SOURCEFORGE_USERNAME" ] || [ -z "$PROJECT_NAME" ]; then
  echo -e "\e[31mError: Missing required fields in private.json!\e[0m"
  exit 1
fi

# Define the upload path on SourceForge
UPLOAD_PATH="$SOURCEFORGE_USERNAME@frs.sourceforge.net:/home/frs/project/$PROJECT_NAME"

# Start SSH session
start_ssh_session

# Find .img and .zip files in the current directory
FILES=($(find . -maxdepth 1 -type f \( -name "*.img" -o -name "*.zip" \)))

if [ ${#FILES[@]} -eq 0 ]; then
  echo -e "\e[31mNo .img or .zip files found to upload.\e[0m"
  end_ssh_session
  exit 1
fi

# Display list of files with numbering and colors
echo -e "\e[1;33mAvailable .img and .zip files for upload:\e[0m"
echo -e "\e[1;32m1)\e[0m \e[34mAll .img and .zip files\e[0m"
echo -e "\e[1;32m2)\e[0m \e[34mUpload a file via custom path\e[0m"

for i in "${!FILES[@]}"; do
  echo -e "\e[1;32m$((i+3)))\e[0m \e[36m${FILES[$i]#./}\e[0m"
done

# Prompt user to select files by number
read -p "Enter the numbers of the files you want to upload (e.g., 2 4 5): " -a selected_numbers

# Function to upload a file
upload_file() {
  local file=$1
  echo -e "\e[34mUploading $file to $UPLOAD_PATH...\e[0m"

  # Use scp with the SSH control socket
  scp -o ControlPath="$SOCKET" "$file" "$UPLOAD_PATH"

  # Check if the upload was successful
  if [ $? -eq 0 ]; then
    echo -e "\e[32mSuccessfully uploaded $file.\e[0m"
  else
    echo -e "\e[31mFailed to upload $file.\e[0m"
  fi
}

# Upload the selected files
for number in "${selected_numbers[@]}"; do
  if [ "$number" -eq 1 ]; then
    # If user selected 1, upload all files
    for file in "${FILES[@]}"; do
      upload_file "$file"
    done
  elif [ "$number" -eq 2 ]; then
    # If user selected 2, prompt for custom file path
    echo -e "\e[34mPlease enter the full path of the file to upload (auto-completion enabled):\e[0m"
    read -e -p "File path: " custom_file
    if [ -f "$custom_file" ]; then
      upload_file "$custom_file"
    else
      echo -e "\e[31mInvalid file path: $custom_file\e[0m"
    fi
  elif [ "$number" -gt 2 ] && [ "$number" -le $(( ${#FILES[@]} + 2 )) ]; then
    # Upload the specific file
    upload_file "${FILES[$((number-3))]}"
  else
    echo -e "\e[31mInvalid selection: $number\e[0m"
  fi
done

# End the SSH session
end_ssh_session

# Display end message
echo -e "\e[1;35m###############################################\e[0m"
echo -e "\e[1;36mScript by Mahesh Technicals - Completed\e[0m"
echo -e "\e[1;35m###############################################\e[0m"
