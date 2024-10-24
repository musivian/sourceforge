
# Upload to SourceForge Script

## Overview

This script allows you to upload files from your local directory to a specified project on SourceForge using SCP (Secure Copy Protocol). It lists available `.img` and `.zip` files, and you can select them for upload. Additionally, the script now includes an option to upload any file via a custom path, enabling users to upload other types of files by specifying the file location.

This script was created by **Mahesh Technicals**.

## Features

- Lists all available `.img` and `.zip` files in the current directory with numbering.
- **New Option:** Allows users to upload a file by providing a custom file path.
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
3. Run the script to upload your files.

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

3. The script will display a list of `.img` and `.zip` files available for upload:
   - Option 1: Upload all `.img` and `.zip` files.
   - Option 2: Upload a file via a custom file path.
   - You will be prompted to select the files or path you want to upload by entering the corresponding number(s).
   - You can select multiple files by entering the numbers separated by spaces (e.g., `2 4 5`).

4. The script will upload the selected files to your SourceForge project and verify the uploaded files.

### Example Output

```bash
###############################################
Script by Mahesh Technicals - Version 1.0
###############################################
jq is already installed.
Available options:
1) All .img and .zip files
2) Upload a file via custom path

Enter the numbers of the files you want to upload (e.g., 1 2): 2
Enter the full path of the file you want to upload: /path/to/customfile.txt
Uploading customfile.txt to your_project_name...
Successfully uploaded customfile.txt.
```

## License

This script is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
