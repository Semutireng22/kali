#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Update package lists and install dependencies
print_message $BLUE "Updating package lists and installing dependencies..."
sudo apt update -y
sudo apt install git nodejs npm screen -y || { print_message $RED "Failed to install dependencies"; exit 1; }
print_message $GREEN "Dependencies installed successfully!"

# Check if a screen session named 'kaleidos' already exists
if screen -ls | grep -q "kaleidos"; then
    print_message $YELLOW "A screen session named 'kaleidos' already exists. Deleting it..."
    screen -S kaleidos -X quit || { print_message $RED "Failed to delete existing screen session"; exit 1; }
    print_message $GREEN "Existing screen session deleted successfully."
fi

# Check if the repository directory already exists
if [ -d "KaleidoFinance-Auto-Bot" ]; then
    print_message $YELLOW "Repository directory 'KaleidoFinance-Auto-Bot' already exists. Deleting it..."
    rm -rf KaleidoFinance-Auto-Bot || { print_message $RED "Failed to delete existing repository"; exit 1; }
    print_message $GREEN "Existing repository deleted successfully."
fi

# Clone the repository
print_message $BLUE "Cloning KaleidoFinance-Auto-Bot repository..."
git clone https://github.com/airdropinsiders/KaleidoFinance-Auto-Bot.git || { print_message $RED "Failed to clone repository"; exit 1; }
cd KaleidoFinance-Auto-Bot || { print_message $RED "Failed to enter directory"; exit 1; }
print_message $GREEN "Repository cloned successfully!"

# Install Node.js dependencies
print_message $BLUE "Installing Node.js dependencies..."
npm install || { print_message $RED "Failed to install Node.js dependencies"; exit 1; }
print_message $GREEN "Node.js dependencies installed successfully!"

# Create wallets.txt and prompt user for their EVM address
print_message $YELLOW "Creating wallets.txt..."
read -p "$(echo -e "${YELLOW}Enter your public EVM address: ${NC}")" evm_address
if [ -z "$evm_address" ]; then
    print_message $RED "EVM address cannot be empty!"
    exit 1
fi
echo "$evm_address" > wallets.txt
print_message $GREEN "wallets.txt created successfully with your EVM address!"

# Start the bot in a new screen session
print_message $BLUE "Starting the bot in a new screen session..."
screen -dmS kaleidos bash -c "npm run start"

# Check if the screen session is running
sleep 2 # Give some time for the screen session to initialize
if screen -ls | grep -q "kaleidos"; then
    print_message $GREEN "Bot has been started in a screen session named 'kaleidos'."
    print_message $YELLOW "To attach to the session, use: ${GREEN}screen -rd kaleidos${NC}"
else
    print_message $RED "Failed to start the bot in a screen session."
    exit 1
fi
