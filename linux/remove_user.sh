#!/bin/bash

# Define a list of protected system users
protected_users=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" "systemd-resolve" "syslog" "messagebus" "_apt" "lxd" "uuidd" "dnsmasq" "landscape" "sshd" "pollinate" "nologin")

while true; do
    # List all users
    echo "List of users:"
    awk -F':' '{ if ($3 >= 1000) print $1}' /etc/passwd

    # Ask for user input
    echo "Enter the username you want to delete or type 'exit' to quit:"
    read username

    # Check if the user wants to exit
    if [ "$username" == "exit" ]; then
        echo "Exiting script."
        exit 0
    fi

    # Check if the user is in the protected list
    if [[ " ${protected_users[@]} " =~ " ${username} " ]]; then
        echo "Error: $username is a protected system user and cannot be deleted."
        continue
    fi

    # Check if the user exists
    if id "$username" &>/dev/null; then
        # Ask for confirmation
        echo "Are you sure you want to delete the user $username? (y/n)"
        read confirmation
        if [ "$confirmation" == "y" ]; then
            sudo userdel $username
            echo "User $username has been deleted."
        else
            echo "User deletion cancelled."
        fi
    else
        echo "User $username does not exist."
    fi

    echo "Press any key to continue..."
    read -n 1
done
