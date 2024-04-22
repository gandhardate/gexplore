#!/bin/bash

# Check if dialog is installed, if not, try to install it
if ! command -v dialog &> /dev/null; then
    echo "dialog is not installed. Attempting to install..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -y dialog
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Sorry, this script doesn't support automatic installation on macOS."
        exit 1
    fi
fi

# Function to display current directory contents
display_files() {
    local choices=()
    local file

    # Get the list of files and directories
    local files=$(ls -a1)

    # Process each file/directory
    while IFS= read -r file; do
        choices+=("$file" "")
    done <<< "$files"

    # Display the menu
    dialog --no-cancel --menu "gExplore - Current directory: $(pwd)" 30 100 20 q "Quit gExplore" "${choices[@]}"  2> /tmp/choice.txt
    local currDir = $(pwd)
    # Read the user's choice
    local choice=$(cat /tmp/choice.txt)
    rm -f /tmp/choice.txt

    # Handle the choice
    if [[ "$choice" == "m" ]]; then
        cd ..
    elif [[ "$choice" == "q" ]]; then
        clear
        echo exited gExplore
        echo Currently at: $(pwd)
        exit 0
    elif [[ -d "$choice" ]]; then
        cd "$choice"
    elif [[ -f "$choice" ]]; then
         # Check if the file is executable
        if [[ -x "$choice" ]]; then
            # Prompt user for confirmation
            dialog --yesno "Do you want to execute '$choice'?" 10 60
            confirm=$?
            if [ $confirm -eq 0 ]; then
                clear
                ./"$choice" # Execute the file
            fi
        else
            vi "$choice" # Open the file in vi
        fi
    fi
}

# Main loop
while true; do
    display_files
done

