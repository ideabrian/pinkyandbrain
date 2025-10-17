#!/bin/bash

# Daily Standup Collector
# Collects daily activity from git commits, messages, and sessions
# Runs daily at 11:59 PM via cron and POSTs to API

set -euo pipefail

# Configuration
MACHINE_NAME="${MACHINE_NAME:-$(hostname -s)}"
REPO_PATH="${REPO_PATH:-$HOME/pinkyandbrain}"
API_ENDPOINT="${API_ENDPOINT:-https://pinky-brain-hub.b-9f2.workers.dev/api/standup}"
AUTH_SECRET="${STANDUP_AUTH_SECRET:-}"

# Date handling (default to today, or accept as argument)
TARGET_DATE="${1:-$(date +%Y-%m-%d)}"
START_TIME="${TARGET_DATE} 00:00:00"
END_TIME="${TARGET_DATE} 23:59:59"

# Ensure jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Run: brew install jq" >&2
    exit 1
fi

# Navigate to repo
cd "$REPO_PATH" || {
    echo "Error: Could not access repository at $REPO_PATH" >&2
    exit 1
}

# Collect git commits for the day
collect_commits() {
    local commits_json
    local raw_commits
    raw_commits=$(git log \
        --all \
        --since="$START_TIME" \
        --until="$END_TIME" \
        --pretty=format:'{"hash":"%H","author":"%an","date":"%aI","message":"%s"}' \
        2>/dev/null || echo "")

    if [[ -z "$raw_commits" ]]; then
        commits_json="[]"
    else
        commits_json=$(echo "$raw_commits" | jq -s '.')
    fi

    echo "$commits_json"
}

# Collect messages sent/received (from message log if available)
collect_messages() {
    local messages_json="[]"
    local message_log="$HOME/pinkyandbrain/logs/messages-${TARGET_DATE}.log"

    if [[ -f "$message_log" ]]; then
        # Parse message log and extract relevant entries
        messages_json=$(grep -E "^(SENT|RECEIVED)" "$message_log" 2>/dev/null | \
            awk -v date="$TARGET_DATE" '{
                type=$1;
                timestamp=$2" "$3;
                gsub(/\[|\]|SENT:|RECEIVED:/, "", type);
                gsub(/\[|\]/, "", timestamp);
                $1=$2=$3="";
                message=substr($0,4);
                print "{\"type\":\""tolower(type)"\",\"timestamp\":\""timestamp"\",\"content\":\""message"\"}";
            }' | jq -s '.' 2>/dev/null || echo "[]")
    fi

    echo "$messages_json"
}

# Collect session information
collect_sessions() {
    local session_log="$HOME/pinkyandbrain/logs/session-${TARGET_DATE}.log"
    local total_commands=0
    local session_duration=0

    if [[ -f "$session_log" ]]; then
        total_commands=$(grep -c "^COMMAND:" "$session_log" 2>/dev/null || echo 0)
        # Estimate session duration from log timestamps (simplified)
        session_duration=$(( $(stat -f%m "$session_log" 2>/dev/null || echo 0) - $(stat -f%B "$session_log" 2>/dev/null || echo 0) ))
    fi

    jq -n \
        --arg commands "$total_commands" \
        --arg duration "$session_duration" \
        '{total_commands: ($commands | tonumber), session_duration_seconds: ($duration | tonumber)}'
}

# Extract highlights from commit messages (commits with ! or feat: prefix)
extract_highlights() {
    local commits="$1"
    echo "$commits" | jq '[.[] | select(.message | test("(!|feat:|feature:)"; "i")) | .message] | unique'
}

# Extract blockers from commit messages (commits with blocked, issue, error, fix)
extract_blockers() {
    local commits="$1"
    echo "$commits" | jq '[.[] | select(.message | test("(blocked?|issue|error|fix)"; "i")) | .message] | unique'
}

# Calculate statistics
calculate_stats() {
    local commits="$1"
    local messages="$2"

    local commit_count
    local message_count
    local files_changed

    commit_count=$(echo "$commits" | jq 'length')
    message_count=$(echo "$messages" | jq 'length')
    files_changed=$(git diff --stat --since="$START_TIME" --until="$END_TIME" 2>/dev/null | tail -1 | awk '{print $1}' || echo 0)

    jq -n \
        --arg commits "$commit_count" \
        --arg messages "$message_count" \
        --arg files "$files_changed" \
        '{
            total_commits: ($commits | tonumber),
            total_messages: ($messages | tonumber),
            files_changed: ($files | tonumber)
        }'
}

# Build the complete standup payload
build_payload() {
    local commits messages sessions highlights blockers stats

    echo "Collecting data for $MACHINE_NAME on $TARGET_DATE..." >&2

    commits=$(collect_commits)
    messages=$(collect_messages)
    sessions=$(collect_sessions)
    highlights=$(extract_highlights "$commits")
    blockers=$(extract_blockers "$commits")
    stats=$(calculate_stats "$commits" "$messages")

    jq -n \
        --arg machine "$MACHINE_NAME" \
        --arg date "$TARGET_DATE" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson commits "$commits" \
        --argjson messages "$messages" \
        --argjson sessions "$sessions" \
        --argjson highlights "$highlights" \
        --argjson blockers "$blockers" \
        --argjson stats "$stats" \
        '{
            machine: $machine,
            date: $date,
            timestamp: $timestamp,
            commits: $commits,
            messages: $messages,
            sessions: $sessions,
            highlights: $highlights,
            blockers: $blockers,
            stats: $stats
        }'
}

# Send payload to API
send_to_api() {
    local payload="$1"

    if [[ -z "$AUTH_SECRET" ]]; then
        echo "Warning: STANDUP_AUTH_SECRET not set, skipping API submission" >&2
        echo "$payload" | jq '.'
        return 0
    fi

    local response
    response=$(curl -s -w "\n%{http_code}" -X POST "$API_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_SECRET" \
        -d "$payload")

    local http_code
    http_code=$(echo "$response" | tail -n1)
    local body
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]] || [[ "$http_code" == "201" ]]; then
        echo "✅ Standup data submitted successfully for $MACHINE_NAME on $TARGET_DATE" >&2
        return 0
    else
        echo "❌ Failed to submit standup data (HTTP $http_code)" >&2
        echo "$body" >&2
        return 1
    fi
}

# Main execution
main() {
    local payload
    payload=$(build_payload)

    # Save locally as backup
    local backup_dir="$HOME/pinkyandbrain/standups"
    mkdir -p "$backup_dir"
    echo "$payload" > "$backup_dir/${MACHINE_NAME}-${TARGET_DATE}.json"
    echo "💾 Saved backup to $backup_dir/${MACHINE_NAME}-${TARGET_DATE}.json" >&2

    # Send to API
    send_to_api "$payload"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
