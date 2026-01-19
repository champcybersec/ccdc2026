#!/bin/bash

# this is so vibecoded it's not even funny
# Script to list all cronjobs for all users with option to delete
# Usage: ./list_all_cronjobs.sh [--delete]

# Global arrays to store cronjob information
declare -a cronjob_list=()
declare -a cronjob_users=()
declare -a cronjob_files=()
declare -a cronjob_types=()
declare -a cronjob_line_numbers=()

# Function to add cronjob to arrays
add_cronjob() {
    local job="$1"
    local user="$2"
    local file="$3"
    local type="$4"
    local line_num="$5"
    
    cronjob_list+=("$job")
    cronjob_users+=("$user")
    cronjob_files+=("$file")
    cronjob_types+=("$type")
    cronjob_line_numbers+=("$line_num")
}

# Function to display all cronjobs with numbers
display_cronjobs() {
    echo "========================================="
    echo "All cronjobs found on the system"
    echo "========================================="
    echo
    
    if [[ ${#cronjob_list[@]} -eq 0 ]]; then
        echo "No cronjobs found."
        return
    fi
    
    for i in "${!cronjob_list[@]}"; do
        local num=$((i + 1))
        echo "[$num] User: ${cronjob_users[$i]} | Type: ${cronjob_types[$i]}"
        if [[ "${cronjob_files[$i]}" != "crontab" ]]; then
            echo "     File: ${cronjob_files[$i]}"
        fi
        echo "     Job: ${cronjob_list[$i]}"
        echo
    done
}

# Function to delete a cronjob
delete_cronjob() {
    local index=$1
    local user="${cronjob_users[$index]}"
    local file="${cronjob_files[$index]}"
    local type="${cronjob_types[$index]}"
    local job="${cronjob_list[$index]}"
    local line_num="${cronjob_line_numbers[$index]}"
    
    echo "Deleting cronjob:"
    echo "User: $user"
    echo "Type: $type"
    echo "Job: $job"
    
    if [[ "$type" == "user_crontab" ]]; then
        # For user crontabs, we need to remove the specific line
        local temp_file=$(mktemp)
        crontab -u "$user" -l 2>/dev/null | grep -v -F "$job" > "$temp_file"
        
        if crontab -u "$user" "$temp_file" 2>/dev/null; then
            echo "✓ Successfully deleted cronjob for user $user"
        else
            echo "✗ Failed to delete cronjob for user $user"
        fi
        rm -f "$temp_file"
        
    elif [[ "$type" == "system_file" ]]; then
        # For system files, we need root privileges
        if [[ $EUID -ne 0 ]]; then
            echo "✗ Root privileges required to delete system cronjobs"
            echo "  Run with sudo to delete system cronjobs"
            return 1
        fi
        
        # Create backup
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Remove the line from the file
        if sed -i "${line_num}d" "$file" 2>/dev/null; then
            echo "✓ Successfully deleted cronjob from $file"
            echo "  Backup created: ${file}.backup.$(date +%Y%m%d_%H%M%S)"
        else
            echo "✗ Failed to delete cronjob from $file"
        fi
        
    elif [[ "$type" == "executable_file" ]]; then
        # For executable files in cron directories
        if [[ $EUID -ne 0 ]]; then
            echo "✗ Root privileges required to delete system cron files"
            echo "  Run with sudo to delete system cron files"
            return 1
        fi
        
        echo "Warning: This will delete the entire executable file: $file"
        read -p "Are you sure? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            if rm "$file" 2>/dev/null; then
                echo "✓ Successfully deleted $file"
            else
                echo "✗ Failed to delete $file"
            fi
        else
            echo "Deletion cancelled"
        fi
    fi
}

# Function to collect all cronjobs
collect_cronjobs() {
    echo "Scanning for cronjobs..."
    echo
    
    # Check if running as root for better access
    if [[ $EUID -ne 0 ]]; then
        echo "Note: Running as non-root user. Some cronjobs may not be accessible."
        echo "For complete access and deletion capabilities, run as root."
        echo
    fi
    
    # Get all users from /etc/passwd
    local users=$(cut -d: -f1 /etc/passwd | sort)
    
    for user in $users; do
        # Check if user has a valid shell
        local user_shell=$(getent passwd "$user" | cut -d: -f7)
        
        # Skip users with no shell or system shells
        if [[ "$user_shell" == "/bin/false" ]] || [[ "$user_shell" == "/usr/sbin/nologin" ]] || [[ "$user_shell" == "/sbin/nologin" ]]; then
            continue
        fi
        
        # Try to get the user's crontab
        local crontab_output=$(crontab -u "$user" -l 2>/dev/null)
        local crontab_exit_code=$?
        
        if [[ $crontab_exit_code -eq 0 ]] && [[ -n "$crontab_output" ]]; then
            # Process each line of the crontab
            local line_num=1
            while IFS= read -r line; do
                # Skip empty lines and comments
                if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
                    add_cronjob "$line" "$user" "crontab" "user_crontab" "$line_num"
                fi
                ((line_num++))
            done <<< "$crontab_output"
        fi
    done
    
    # Check system-wide cron files
    
    # Check /etc/crontab
    if [[ -f /etc/crontab ]]; then
        local line_num=1
        while IFS= read -r line; do
            # Skip empty lines and comments
            if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ ! "$line" =~ ^[[:space:]]*[A-Z] ]]; then
                add_cronjob "$line" "system" "/etc/crontab" "system_file" "$line_num"
            fi
            ((line_num++))
        done < /etc/crontab
    fi
    
    # Check cron.d directory
    if [[ -d /etc/cron.d ]]; then
        for file in /etc/cron.d/*; do
            if [[ -f "$file" ]]; then
                local line_num=1
                while IFS= read -r line; do
                    # Skip empty lines and comments
                    if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
                        add_cronjob "$line" "system" "$file" "system_file" "$line_num"
                    fi
                    ((line_num++))
                done < "$file"
            fi
        done
    fi
    
    # Check executable cron directories
    for dir in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly; do
        if [[ -d "$dir" ]]; then
            for file in "$dir"/*; do
                if [[ -f "$file" ]] && [[ -x "$file" ]]; then
                    local basename_file=$(basename "$file")
                    local schedule=""
                    case "$dir" in
                        */cron.hourly) schedule="Hourly" ;;
                        */cron.daily) schedule="Daily" ;;
                        */cron.weekly) schedule="Weekly" ;;
                        */cron.monthly) schedule="Monthly" ;;
                    esac
                    add_cronjob "$schedule execution of $basename_file" "system" "$file" "executable_file" "1"
                fi
            done
        fi
    done
}

# Main execution
collect_cronjobs
display_cronjobs

# Check if delete mode is requested
if [[ "$1" == "--delete" ]] || [[ "$1" == "-d" ]]; then
    if [[ ${#cronjob_list[@]} -eq 0 ]]; then
        echo "No cronjobs to delete."
        exit 0
    fi
    
    echo "========================================="
    echo "Delete Mode"
    echo "========================================="
    echo
    
    while true; do
        echo "Enter the number of the cronjob to delete (1-${#cronjob_list[@]}), 'q' to quit, or 'r' to refresh:"
        read -p "> " choice
        
        if [[ "$choice" == "q" ]] || [[ "$choice" == "quit" ]]; then
            echo "Exiting delete mode."
            break
        elif [[ "$choice" == "r" ]] || [[ "$choice" == "refresh" ]]; then
            # Refresh the list
            cronjob_list=()
            cronjob_users=()
            cronjob_files=()
            cronjob_types=()
            cronjob_line_numbers=()
            collect_cronjobs
            display_cronjobs
            continue
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#cronjob_list[@]} ]]; then
            local index=$((choice - 1))
            echo
            delete_cronjob "$index"
            echo
            
            # Ask if user wants to continue
            read -p "Delete another cronjob? (y/N): " continue_delete
            if [[ ! "$continue_delete" =~ ^[Yy]$ ]]; then
                break
            fi
            
            # Refresh the list after deletion
            cronjob_list=()
            cronjob_users=()
            cronjob_files=()
            cronjob_types=()
            cronjob_line_numbers=()
            collect_cronjobs
            display_cronjobs
        else
            echo "Invalid choice. Please enter a number between 1 and ${#cronjob_list[@]}, 'q' to quit, or 'r' to refresh."
        fi
    done
else
    echo "========================================="
    echo "Usage:"
    echo "  $0           - List all cronjobs"
    echo "  $0 --delete  - List and delete cronjobs interactively"
    echo "  $0 -d        - Same as --delete"
    echo "========================================="
fi
