#!/bin/bash

# run-on-all.sh - Execute commands across all machines in parallel
# Usage: ./run-on-all.sh "command to run"
# Example: ./run-on-all.sh "whoami && hostname"

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Machine list
MACHINES=("localhost" "pinky" "brain")

# Check if command provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No command provided${NC}"
    echo "Usage: $0 \"command to run\""
    echo "Example: $0 \"hostname && date\""
    exit 1
fi

COMMAND="$1"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   Running on all machines in parallel${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Command:${NC} $COMMAND"
echo ""

# Function to run command on a machine
run_on_machine() {
    local machine=$1
    local cmd=$2

    echo -e "${GREEN}━━━ $machine ━━━${NC}"

    if [ "$machine" = "localhost" ]; then
        # Run locally
        eval "$cmd" 2>&1 | sed "s/^/  /"
    else
        # Run via SSH
        ssh "$machine" "$cmd" 2>&1 | sed "s/^/  /"
    fi

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ $machine completed successfully${NC}"
    else
        echo -e "${RED}✗ $machine failed (exit code: $exit_code)${NC}"
    fi

    echo ""
}

# Export function for parallel execution
export -f run_on_machine
export COMMAND RED GREEN BLUE YELLOW NC

# Run on all machines in parallel
for machine in "${MACHINES[@]}"; do
    run_on_machine "$machine" "$COMMAND" &
done

# Wait for all background jobs
wait

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}All machines completed${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
