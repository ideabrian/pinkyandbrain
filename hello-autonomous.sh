#!/bin/bash

################################################################################
# hello-autonomous.sh
#
# A demonstration script for Claude Code autonomous execution mode.
# This script tests various shell operations including:
# - Printing messages with emoji
# - Displaying current date/time
# - Listing .sh files in the current directory
# - Proper error handling with set -e
#
# Created by: Autonomous Claude Code (pinky)
# Date: 2025-10-16
################################################################################

# Exit immediately if a command exits with a non-zero status
set -e

# Print welcome message
echo "🤖 Autonomous Claude Code is WORKING!"
echo ""

# Show current date and time
echo "Current date and time:"
date
echo ""

# List all .sh files in ~/pinkyandbrain directory
echo "Shell scripts in ~/pinkyandbrain directory:"
if ls ~/pinkyandbrain/*.sh 2>/dev/null; then
    echo ""
    echo "Total .sh files found: $(ls ~/pinkyandbrain/*.sh 2>/dev/null | wc -l | tr -d ' ')"
else
    echo "No .sh files found in ~/pinkyandbrain directory"
fi

echo ""
echo "✅ Script execution completed successfully!"
