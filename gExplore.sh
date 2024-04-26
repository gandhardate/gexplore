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
# flag for quitting
KEEP_EXPLORING=true
# path of recent directory
LAST_DIR=""
# flag to toggle more options
MORE_OPTIONS_FLAG=false
toggle_more_options() {
     if [ "$MORE_OPTIONS_FLAG" = true ]; then
        MORE_OPTIONS_FLAG=false
    else
        MORE_OPTIONS_FLAG=true
    fi
}
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
    if $MORE_OPTIONS_FLAG; then
        dialog --no-cancel --menu "gExplore - Current directory: $(pwd)" 30 100 20 q "Quit gExplore" m "Toggle More options On/Off" a "about" h "help" "${choices[@]}" 2> /tmp/choice.txt
    else
        dialog --no-cancel --menu "gExplore - Current directory: $(pwd)" 30 100 20 q "Quit gExplore" m "Toggle More options On/Off" "${choices[@]}"  2> /tmp/choice.txt
    fi

    # Read the user's choice
    local choice=$(cat /tmp/choice.txt)
    rm -f /tmp/choice.txt

    # Handle the choice
    if [[ "$choice" == "m" ]]; then
        toggle_more_options
    elif [[ "$choice" == "q" ]]; then
        clear
        echo Last location opened in gexplore: $(pwd)
        LAST_DIR=$(pwd)
        KEEP_EXPLORING=false
    elif [[ "$choice" == "a" ]]; then
        dialog --msgbox "gExplore v2.0\nGitHub Link: https://github.com/gandhardate/gexplore\nBy Gandhar Date" 10 70
    elif [[ "$choice" == "h" ]]; then
        dialog --msgbox "gExplore v2.0 help\nLaunch gexplore anywhere\n 1. Navigate between directories\n 2. Toggle switch for more options\n " 10 70
   
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
while $KEEP_EXPLORING; do
    display_files
done
echo exited gexplore

