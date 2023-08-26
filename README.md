# ISC-DShield-Escape-Hunter

A tool designed to work in conjunction with the ISC DShield system. Its primary purpose is to identify and report on potential escape sequences present in logs and downloads, enhancing the security posture of your environment.

## Features
- **Superuser Privilege Check**: Ensures the script runs with the necessary permissions.
- **Downloaded Files Analysis**: Scans downloaded files for potential escape sequences.
- **TTY Log Analysis**: Processes TTY logs to identify escape sequences.
- **HTTP Webhoneypot Log Analysis**: Examines the last two weeks of webhoneypot logs for escape sequences.

## Requirements
- DShield installed
- jq installed (for JSON parsing)
- Access to relevant log directories
- Superuser privileges for certain checks

## Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/stsparrow/ISC-DShield-Escape-Hunter.git
   cd ISC-DShield-Escape-Hunter
   chmod +x escape_hunter.sh
   sudo ./escape_hunter.sh

Contribution
Feel free to submit issues or pull requests if you identify any bugs or have suggestions for improvements.

License
MIT

Disclaimer
Ensure you have the necessary permissions before scanning or altering any system or file. The creator of this tool are not responsible for misuse or any potential damage caused.
