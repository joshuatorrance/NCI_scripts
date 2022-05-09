#!/bin/bash

# This script goes to Gadi and runs the nci-file-expiry command
#  to get a list of files that are due to expire soon. Since we
#  cannot send mail or run crontabs on Gadi this should be setup
#  on AccessDev or similar.
# The cron entry for this script should look something like the
#  following if you want it to run at midnight every day:
#  * 0 * * * /home/548/jt4085/cron_scripts/nci_file_expiry_email.sh
# Remember to chmod +x this script.

# SSH to gadi and run the file expiry command
#  Take the first 100 results to not overwhelm
#  the connection or the user.
#  Assume ssh keys have been setup.
# Discard stderr since .bashrc might produce stderr output
result=`ssh gadi "nci-file-expiry list-warnings | head -n 101" 2> /dev/null`

# In case .bashrc is outputting to stdout use sed to discard
#  everything before the header line of nci-file-expiry
result=`echo $result | \
        sed '/EXPIRES AT           GROUP     SIZE  PATH/,$!d'`

# If the remaining output is only one line then it's just header
#  send a message indicating there's no output of note.
num_lines=`echo "$result" | wc -l`

if [[ $num_line -le 1 ]]; then
    message="Files due to expire have been found.\n"
    message="${message}The top $(num_lines-1) files are:\n"
    message="${message}$result"
fi

# If a message has been set then send an mail to the user
#  which will get sent to their email.
if [[ -n "$message" ]]; then
    echo "$message" | mail -s "NCI File Expiry Report" $USER
fi

