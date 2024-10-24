# Upload to SourceForge Script

## Overview

This script allows you to upload `.img` and `.zip` files from your local directory to a specified project on SourceForge using SCP (Secure Copy Protocol). You can select which files to upload from a numbered list and can choose to upload multiple files at once.

This script was created by **Mahesh Technicals**.

## Features

- Lists all available `.img` and `.zip` files in the current directory with a number.
- Allows selection of specific files to upload or uploading all files at once.
- Verifies the uploaded files on SourceForge after completion.
- Includes colorful terminal output for an enhanced user experience.
- Automatically installs necessary dependencies (`jq`).

## Requirements

- `jq`: Used to parse `private.json` for SourceForge credentials.
- `scp`: Secure Copy for file uploads over SSH.
- A SourceForge account with a project to upload the files to.

## Usage

1. Clone or download this script.
2. Ensure you have a `private.json` file with your SourceForge credentials (see format below).
3. Run the script to upload your `.img` and `.zip` files.

### `private.json` Format

The script uses a `private.json` file to retrieve your SourceForge credentials and project information. The format of the `private.json` file should be as follows:

```json
{
  "username": "your_sourceforge_username",
  "project": "your_project_name"
}
```

- `username`: Your SourceForge username.
- `project`: The name of your SourceForge project where files will be uploaded.

### Running the Script

1. Make the script executable:

   ```bash
   chmod +x upload_to_sourceforge.sh
   ```

2. Run the script:

   ```bash
   ./upload_to_sourceforge.sh
   ```

3. The script will display a list of `.img` and `.zip` files available for upload.
   - You will be prompted to select the files you want to upload by entering the corresponding numbers.
   - You can select multiple files by entering the numbers separated by spaces (e.g., `2 4 5`).

4. The script will upload the selected files to your SourceForge project and verify the uploaded files.

### Example Output

```bash
###############################################
Script by Mahesh Technicals
###############################################
jq is already installed.
Available .img and .zip files for upload:
1) All .img and .zip files
2) image1.img
3) rom.zip
4) kernel.img

Enter the numbers of the files you want to upload (e.g., 2 4 5): 2 3
Uploading image1.img to your_project_name...
Successfully uploaded image1.img.
Uploading rom.zip to your_project_name...
Successfully uploaded rom.zip.
Verifying uploaded files in the project your_project_name...
```

## License

This script is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
