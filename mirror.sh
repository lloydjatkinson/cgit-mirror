#!/bin/sh

REPOS_DIR="/srv/git"

echo "Starting repository operations at $(date)"

# Install git if needed (for setup container)
if ! command -v git > /dev/null 2>&1; then
    echo "Installing git..."
    apk add --no-cache git
fi

# Change to the repositories directory
cd "$REPOS_DIR"

# Find all directories that might be git repositories
REPOS=$(find . -maxdepth 1 -type d)
REPO_COUNT=$(echo "$REPOS" | grep -c '.')

# Check if any repositories were found
if [ "$REPO_COUNT" -eq 0 ]; then
    echo "No directories found in $REPOS_DIR"
else
    echo "Found $REPO_COUNT director$([ "$REPO_COUNT" -eq 1 ] && echo "y" || echo "ies"):"
    
    # List directories
    echo "$REPOS" | while read -r repo; do
        echo " - $repo"
        # Check if it's a git repository
        if [ -d "$repo/.git" ]; then
            echo "   This is a Git repository"
        fi
    done

    # Update repositories
    echo "$REPOS" | while read -r repo; do
        if [ -d "$repo/.git" ]; then
            cd "$repo"
            echo "Updating repository: $repo"
            git fetch --all
            git remote update
            echo "Last 5 commits:"
            git log -n 5 --pretty=format:"     - %h %ad %s" --date=short
            cd - > /dev/null
        fi
    done
fi

# Optional: Add logging
echo "Repository update completed at $(date)"