#!/bin/bash

# Script to list all cronjobs for all users
# Usage: ./list_all_cronjobs.sh

echo "========================================="
echo "Listing all cronjobs for all users"
echo "========================================="
echo

# Check if running as root for better access
if [[ $EUID -ne 0 ]]; then
    echo "Note: Running as non-root user. Some user crontabs may not be accessible."
    echo "For complete results, run as root: sudo ./list_all_cronjobs.sh"
    echo
fi

# Get all users from /etc/passwd
users=$(cut -d: -f1 /etc/passwd | sort)

found_cronjobs=false

for user in $users; do
    # Skip system users that typically don't have cronjobs
    # (users with UID < 1000 are usually system users)
    user_id=$(id -u "$user" 2>/dev/null)
    
    # Check if user has a valid shell (not /bin/false, /usr/sbin/nologin, etc.)
    user_shell=$(getent passwd "$user" | cut -d: -f7)
    
    # Skip users with no shell or system shells
    if [[ "$user_shell" == "/bin/false" ]] || [[ "$user_shell" == "/usr/sbin/nologin" ]] || [[ "$user_shell" == "/sbin/nologin" ]]; then
        continue
    fi
    
    # Try to get the user's crontab
    crontab_output=$(crontab -u "$user" -l 2>/dev/null)
    crontab_exit_code=$?
    
    if [[ $crontab_exit_code -eq 0 ]] && [[ -n "$crontab_output" ]]; then
        echo "--- Cronjobs for user: $user ---"
        echo "$crontab_output"
        echo
        found_cronjobs=true
    elif [[ $crontab_exit_code -eq 1 ]]; then
        # Exit code 1 typically means no crontab for user (not an error)
        continue
    else
        # Other exit codes might indicate permission issues
        echo "--- User: $user ---"
        echo "Unable to access crontab (permission denied or other error)"
        echo
    fi
done

# Check system-wide cron directories
echo "========================================="
echo "System-wide cron jobs"
echo "========================================="
echo

# Check /etc/crontab
if [[ -f /etc/crontab ]]; then
    echo "--- /etc/crontab ---"
    cat /etc/crontab
    echo
    found_cronjobs=true
fi

# Check cron.d directory
if [[ -d /etc/cron.d ]] && [[ -n "$(ls -A /etc/cron.d 2>/dev/null)" ]]; then
    echo "--- /etc/cron.d/ ---"
    for file in /etc/cron.d/*; do
        if [[ -f "$file" ]]; then
            echo "File: $(basename "$file")"
            cat "$file"
            echo
            found_cronjobs=true
        fi
    done
fi

# Check other cron directories
for dir in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly; do
    if [[ -d "$dir" ]] && [[ -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
        echo "--- $dir ---"
        ls -la "$dir"
        echo
        found_cronjobs=true
    fi
done

if [[ "$found_cronjobs" == false ]]; then
    echo "No cronjobs found for any users or in system directories."
fi

echo "========================================="
echo "Cronjob listing complete"
echo "========================================="
