#!/bin/bash

# Created 26th of August 2023
# Author James Turner
# Email stsparrow.jt@gmail.com
# Repository URL github.com/stsparrow/ISC-DShield-Escape-Hunter
# License MIT
# Disclaimer ensure you have the necessary permissions before scanning or altering any system or file.
# The creator of this tool are not responsible for misuse or any potential damage caused.

# Check if the script is run with superuser privileges
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with sudo or as root."
   exit 1
fi
#Check and process downloads directory
DOWNLOAD_DIRECTORY="/srv/cowrie/var/lib/cowrie/downloads"
 
#Check if the directory exists
if [ ! -d "$DOWNLOAD_DIRECTORY" ]; then
    echo "Directory $DOWNLOAD_DIRECTORY does not exist!"
    exit 1
fi

#Loop though files in the directory
echo "***PROCESSING DOWNLOADS***"
echo "Searching in $DOWNLOAD_DIRECTORY for files with escape sequences..."
for file in "$DOWNLOAD_DIRECTORY"/*; do
    if [ -f "$file" ]; then
		#Examine the file header for conditions 'data,ASCII,UTF-' but not a gzip (omit gzip data) feel free to adjust
        if sudo file "$file" | grep -Eq 'data|ASCII|UTF-' && sudo file "$file" | grep -vq 'gzip'; then
            #Look for escape sequences 
 		if grep -qP "|||\e" "$file"; then
                echo "Escape sequence found in: $file"
                ls -la "$file"
                sudo file "$file"
                FOUND=1
				echo "-----------------------"
                echo "Raw content (last 10 lines):"
                echo -e "[32m"
 			#Get contents of the file (but just the end)
                tail -n 10 "$file" | cat -v
                echo -e "[0m"
                FOUND=1
				echo "-----------------------"
            fi
        fi
    fi
done

# Check escape sequences in tty logs
TTY_DIRECTORY="/srv/cowrie/var/log/cowrie/cowrie.log*"
echo "***PROCESSING TTY LOGS***"
echo "Searching in $TTY_DIRECTORY..."
# For each log file, look for evidence of escape sequences in the text of the TTY sessions
for logfile in $TTY_DIRECTORY; do
    echo -n "Examining TTY log $logfile... "
    # Escape sequences in tty logs being examined
    if grep -a -qP "|||\e" "$logfile"; then
        echo -e "Escape sequence found in: $logfile"
        ls -la "$logfile"
		echo "-----------------------"
        echo "Lines with escape sequences:"
        echo -e "[32m"
        grep -a -nP "|||\e" "$logfile" | cat -v
        echo -e "[0m"
		echo "-----------------------"
    else
        echo -e "[33mno escape sequences found[0m"
    fi
done

#Flag to track if any escape sequences were found
FOUND=0  
#Dynamically compute filenames for the past 14 days for inspection or we might read EVERY File
echo "***PROCESSING WEB LOGS***"
echo "This may take a while depending on size of log files"
for i in {0..13}; do
    DATE=$(date -d "-$i days" +"%Y%m%d")
	#webhoneypot log files look like this YYYYMMDD_webhoneypot.json															
    LOG_FILE="/srv/db/${DATE}_webhoneypot.json"
    if [ -f "$LOG_FILE" ]; then
        echo -n "Examining WEB log file: $LOG_FILE... "
    	#Use jq to filter entries containing the specified escape sequences in either the url or data field
		while IFS= read -r entry; do
				url=$(echo "$entry" | jq -r '.url')
				data=$(echo "$entry" | jq -r '.data')
				combined="$url$data"
			
				#Search for URL encoded escape sequences
				if echo "$combined" | grep -Eq "%0a|%1B|%27|%5C033|%5Ce"; then
					echo -e "Escape sequence found in HTTP log: $LOG_FILE"
					echo -e "[32m"
					echo "URL: $url"
					if [ "$data" != "null" ]; then
						echo "Data: $data"
					fi
					echo -e "[0m"
					FOUND=1
					echo "-----------------------"
				fi
		done < <(jq -c '.[] | fromjson | select((.url + .data) | contains("%0a") or contains("%1B") or contains("%27") or contains("%5C033") or contains("%5Ce"))' "$LOG_FILE")
		if [ $FOUND -eq 0 ]; then
			echo -e "[33mno escape sequences found[0m"
		fi
		FOUND=0  # Reset the flag for the next log
    fi
done
