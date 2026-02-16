#!/bin/bash

# Check if the script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Function to update all Docker containers
update_containers() {
    echo "Updating all Docker containers..."
    docker compose pull && docker compose down && docker compose up -d
    echo "Containers updated."
}

# Function to force recreate container
force_recreate() {
    echo "Force recreating container"
    docker compose up -d --force-recreate
    echo "Container recreated"
}

# Function to check system resources
check_resources() {
    echo "Checking Docker container resources"
    docker stats && df -h
    echo "Stats retrieved"
}  

# Function to destroy all Docker containers
destroy_containers() {
    echo "Destroying all Docker containers..."
    docker compose down
    echo "Containers destroyed."
}

# Function to clean up Docker cache and unused data
cleanup_docker() {
    echo "Cleaning up Docker cache and unused data..."
    docker system prune -f
    echo "Docker cleanup completed."
}

# Function to prune Docker images
prune_images() {
    echo "Pruning Docker images..."
    docker image prune -af
    echo "Docker images pruned."
}

# Function to check the status of all Docker containers
check_status() {
    echo "Checking status of all Docker containers..."
    docker compose ps -a
}

# Main menu
while true; do
    echo "Docker Management Script"
    echo "1. Update containers"
    echo "2. Force recreate container"
    echo "3. Destroy containers"
    echo "4. Clean up cache and unused data"
    echo "5. Prune images"
    echo "6. Check Resources"
    echo "7. List containers"
    echo "8. Exit"
    read -p "Choose an option (1-7): " choice

    case $choice in
        1) update_containers ;;
        2) force_recreate ;;
        3) destroy_containers ;;
        4) cleanup_docker ;;
        5) prune_images ;;
        6) check_resources ;;
        7) check_status ;;
        8) echo "Exiting..."; break ;;
        *) echo "Invalid option. Please choose a valid option (1-6)." ;;
    esac
done