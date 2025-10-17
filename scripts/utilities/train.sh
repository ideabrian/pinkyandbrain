#!/bin/bash

# train.sh - Interactive training for thinking with three machines
# Usage: ./train.sh [level]

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

PROGRESS_FILE="$HOME/.pinky-brain-training"

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
    cat > "$PROGRESS_FILE" <<EOF
level1a=0
level1b=0
level1c=0
level2a=0
level2b=0
level3a=0
level3b=0
level4a=0
level4b=0
level4c=0
level5a=0
level5b=0
level5c=0
level6a=0
level6b=0
level6c=0
level8a=0
level8b=0
level8c=0
master1=0
master2=0
master3=0
EOF
fi

# Mark challenge complete
mark_complete() {
    local challenge=$1
    sed -i '' "s/^${challenge}=.*/${challenge}=1/" "$PROGRESS_FILE"
}

# Check if challenge is complete
is_complete() {
    local challenge=$1
    grep "^${challenge}=1" "$PROGRESS_FILE" >/dev/null 2>&1
}

# Get completion percentage
get_progress() {
    local total=22
    local completed=$(grep "=1" "$PROGRESS_FILE" | wc -l | tr -d ' ')
    echo $(( completed * 100 / total ))
}

# Show banner
show_banner() {
    clear
    echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}         🎮 TRAIN THE HUMAN 🎮${NC}"
    echo -e "${MAGENTA}      Learn to Think with Three Machines${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
    echo ""
    local progress=$(get_progress)
    echo -e "${CYAN}Progress: ${progress}% complete${NC}"
    echo ""
}

# Show level menu
show_menu() {
    echo "Choose your training level:"
    echo ""
    echo "  1) Level 1: Communication Basics"
    echo "  2) Level 2: Parallel Execution"
    echo "  3) Level 3: Message Bus Coordination"
    echo "  4) Level 4: Role-Based Thinking"
    echo "  5) Level 5: Real Workflows"
    echo "  6) Level 6: Cloud Bus & Timeline"
    echo "  7) Level 8: Team Communication"
    echo "  8) Master Challenges"
    echo ""
    echo "  p) Show Progress"
    echo "  q) Quit"
    echo ""
    read -p "Enter your choice: " choice
}

# Check achievements and award badges
check_achievements() {
    local progress=$(get_progress)

    # Level completion badges
    if is_complete "level1a" && is_complete "level1b" && is_complete "level1c"; then
        if ! grep -q "badge_communicator=1" "$PROGRESS_FILE" 2>/dev/null; then
            echo "badge_communicator=1" >> "$PROGRESS_FILE"
            echo ""
            echo -e "${MAGENTA}🏆 ACHIEVEMENT UNLOCKED: Cluster Communicator!${NC}"
            echo "You've mastered parallel communication across all machines."
            sleep 2
        fi
    fi

    if is_complete "level2a" && is_complete "level2b"; then
        if ! grep -q "badge_parallel=1" "$PROGRESS_FILE" 2>/dev/null; then
            echo "badge_parallel=1" >> "$PROGRESS_FILE"
            echo ""
            echo -e "${MAGENTA}🏆 ACHIEVEMENT UNLOCKED: Parallel Thinker!${NC}"
            echo "You understand the power of simultaneous execution."
            sleep 2
        fi
    fi

    if is_complete "level3a" && is_complete "level3b"; then
        if ! grep -q "badge_messenger=1" "$PROGRESS_FILE" 2>/dev/null; then
            echo "badge_messenger=1" >> "$PROGRESS_FILE"
            echo ""
            echo -e "${MAGENTA}🏆 ACHIEVEMENT UNLOCKED: Message Master!${NC}"
            echo "Machines obey your communication commands."
            sleep 2
        fi
    fi

    if is_complete "level4a" && is_complete "level4b" && is_complete "level4c"; then
        if ! grep -q "badge_orchestrator=1" "$PROGRESS_FILE" 2>/dev/null; then
            echo "badge_orchestrator=1" >> "$PROGRESS_FILE"
            echo ""
            echo -e "${MAGENTA}🏆 ACHIEVEMENT UNLOCKED: Role Orchestrator!${NC}"
            echo "You think in roles, not machines. Wisdom achieved."
            sleep 2
        fi
    fi

    if is_complete "level5a" && is_complete "level5b" && is_complete "level5c"; then
        if ! grep -q "badge_autonomous=1" "$PROGRESS_FILE" 2>/dev/null; then
            echo "badge_autonomous=1" >> "$PROGRESS_FILE"
            echo ""
            echo -e "${MAGENTA}🏆 ACHIEVEMENT UNLOCKED: Autonomous Architect!${NC}"
            echo "You build self-running systems. The future is now."
            sleep 2
        fi
    fi

    if is_complete "level6a" && is_complete "level6b" && is_complete "level6c"; then
        if ! grep -q "badge_cloud=1" "$PROGRESS_FILE" 2>/dev/null; then
            echo "badge_cloud=1" >> "$PROGRESS_FILE"
            echo ""
            echo -e "${MAGENTA}🏆 ACHIEVEMENT UNLOCKED: Cloud Commander!${NC}"
            echo "Global coordination is your playground."
            sleep 2
        fi
    fi

    # Speedrun achievement
    if [ "$progress" -eq 100 ]; then
        if ! grep -q "badge_master=1" "$PROGRESS_FILE" 2>/dev/null; then
            echo "badge_master=1" >> "$PROGRESS_FILE"
            echo ""
            echo -e "${MAGENTA}═════════════════════════════════════════${NC}"
            echo -e "${MAGENTA}🎓 ULTIMATE ACHIEVEMENT: CLUSTER MASTER! 🎓${NC}"
            echo -e "${MAGENTA}═════════════════════════════════════════${NC}"
            echo ""
            echo "You are now a distributed systems expert."
            echo "The machines are your instruments."
            echo "Build something the world has never seen."
            sleep 3
        fi
    fi
}

# Show progress report
show_progress() {
    clear
    show_banner
    echo -e "${CYAN}📊 Training Progress Report${NC}"
    echo ""

    check_status() {
        if is_complete "$1"; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}○${NC}"
        fi
    }

    echo "Level 1: Communication Basics"
    echo "  $(check_status level1a) Challenge 1a: The Ping"
    echo "  $(check_status level1b) Challenge 1b: Status Check"
    echo "  $(check_status level1c) Challenge 1c: File Hunt"
    echo ""

    echo "Level 2: Parallel Execution"
    echo "  $(check_status level2a) Challenge 2a: Sequential vs Parallel"
    echo "  $(check_status level2b) Challenge 2b: Real Work"
    echo ""

    echo "Level 3: Message Bus"
    echo "  $(check_status level3a) Challenge 3a: Health Check"
    echo "  $(check_status level3b) Challenge 3b: Cross-Machine Messaging"
    echo ""

    echo "Level 4: Role-Based Thinking"
    echo "  $(check_status level4a) Challenge 4a: Assign Roles"
    echo "  $(check_status level4b) Challenge 4b: Run as Brain"
    echo "  $(check_status level4c) Challenge 4c: Run as Pinky"
    echo ""

    echo "Level 5: Real Workflows"
    echo "  $(check_status level5a) Challenge 5a: Autonomous Workflow"
    echo "  $(check_status level5b) Challenge 5b: Monitor Timeline"
    echo "  $(check_status level5c) Challenge 5c: Share Knowledge"
    echo ""

    echo "Level 6: Cloud Bus & Timeline"
    echo "  $(check_status level6a) Challenge 6a: Cloud Bus Status"
    echo "  $(check_status level6b) Challenge 6b: Post Timeline Event"
    echo "  $(check_status level6c) Challenge 6c: Query Knowledge Base"
    echo ""

    echo "Level 8: Team Communication"
    echo "  $(check_status level8a) Challenge 8a: Send Good Morning"
    echo "  $(check_status level8b) Challenge 8b: Check Messages"
    echo "  $(check_status level8c) Challenge 8c: Morning Routine"
    echo ""

    echo "Master Challenges"
    echo "  $(check_status master1) Custom Workflow"
    echo "  $(check_status master2) Dashboard"
    echo "  $(check_status master3) Fault Tolerance"
    echo ""

    # Show badges earned
    echo -e "${YELLOW}🏆 Achievements Unlocked:${NC}"
    grep -q "badge_communicator=1" "$PROGRESS_FILE" 2>/dev/null && echo "  🌐 Cluster Communicator"
    grep -q "badge_parallel=1" "$PROGRESS_FILE" 2>/dev/null && echo "  ⚡ Parallel Thinker"
    grep -q "badge_messenger=1" "$PROGRESS_FILE" 2>/dev/null && echo "  📨 Message Master"
    grep -q "badge_orchestrator=1" "$PROGRESS_FILE" 2>/dev/null && echo "  🎭 Role Orchestrator"
    grep -q "badge_autonomous=1" "$PROGRESS_FILE" 2>/dev/null && echo "  🤖 Autonomous Architect"
    grep -q "badge_cloud=1" "$PROGRESS_FILE" 2>/dev/null && echo "  ☁️ Cloud Commander"
    grep -q "badge_master=1" "$PROGRESS_FILE" 2>/dev/null && echo "  🎓 CLUSTER MASTER"
    echo ""

    local progress=$(get_progress)
    if [ "$progress" -eq 100 ]; then
        echo -e "${GREEN}🎓 CONGRATULATIONS! You've mastered the cluster!${NC}"
        echo ""
        echo "You now think like a distributed system."
        echo "Time to build something awesome with your three minds."
    else
        echo -e "${CYAN}Progress: ${progress}% - Keep going!${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
}

# Level 1: Communication Basics
level1() {
    clear
    show_banner
    echo -e "${BLUE}━━━ Level 1: Communication Basics ━━━${NC}"
    echo ""
    echo "Learn to use run-on-all.sh for instant cluster-wide communication."
    echo ""
    echo "Challenges:"
    echo "  a) The Ping"
    echo "  b) Status Check"
    echo "  c) File Hunt"
    echo "  r) Return to menu"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose challenge: ${NC})" choice

    case $choice in
        a)
            echo ""
            echo -e "${CYAN}Challenge 1a: The Ping${NC}"
            echo ""
            echo "Run this command to ping all three machines:"
            echo ""
            echo -e "${GREEN}./run-on-all.sh \"echo 'Hello from \$(hostname)!'\"${NC}"
            echo ""
            read -p "Press Enter when ready to run..."
            ./run-on-all.sh "echo 'Hello from $(hostname)!'"
            echo ""
            echo -e "${GREEN}✓ You just communicated with all three machines in parallel!${NC}"
            echo ""
            echo "Lesson: Stop SSHing into each machine. Use run-on-all.sh."
            mark_complete "level1a"
            check_achievements
            read -p "Press Enter to continue..."
            level1
            ;;
        b)
            echo ""
            echo -e "${CYAN}Challenge 1b: Status Check${NC}"
            echo ""
            echo "Check uptime on all machines simultaneously:"
            echo ""
            echo -e "${GREEN}./run-on-all.sh \"uptime\"${NC}"
            echo ""
            read -p "Press Enter when ready to run..."
            ./run-on-all.sh "uptime"
            echo ""
            echo -e "${GREEN}✓ Instant cluster health snapshot!${NC}"
            mark_complete "level1b"
            check_achievements
            read -p "Press Enter to continue..."
            level1
            ;;
        c)
            echo ""
            echo -e "${CYAN}Challenge 1c: File Hunt${NC}"
            echo ""
            echo "List files in ~/pinkyandbrain on all machines:"
            echo ""
            echo -e "${GREEN}./run-on-all.sh \"ls -la ~/pinkyandbrain\"${NC}"
            echo ""
            read -p "Press Enter when ready to run..."
            ./run-on-all.sh "ls -la ~/pinkyandbrain"
            echo ""
            echo -e "${GREEN}✓ You can see what's deployed everywhere!${NC}"
            mark_complete "level1c"
            check_achievements
            read -p "Press Enter to continue..."
            level1
            ;;
        r)
            return
            ;;
    esac
}

# Level 2: Parallel Execution
level2() {
    clear
    show_banner
    echo -e "${BLUE}━━━ Level 2: Parallel Execution ━━━${NC}"
    echo ""
    echo "Time is money. Three machines = 3x faster."
    echo ""
    echo "Challenges:"
    echo "  a) Sequential vs Parallel (demo)"
    echo "  b) Parallel Node Version Check"
    echo "  r) Return to menu"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose challenge: ${NC})" choice

    case $choice in
        a)
            echo ""
            echo -e "${CYAN}Challenge 2a: Sequential vs Parallel${NC}"
            echo ""
            echo "Watch the difference between sequential and parallel:"
            echo ""
            echo -e "${YELLOW}Sequential (slow):${NC}"
            time (
                echo "  maxyolo..." && sleep 2
                echo "  pinky..." && sleep 2
                echo "  brain..." && sleep 2
            )
            echo ""
            echo -e "${YELLOW}Parallel (fast):${NC}"
            time ./run-on-all.sh "sleep 2 && echo 'Done!'"
            echo ""
            echo -e "${GREEN}✓ Parallelism is a superpower!${NC}"
            echo "Notice: Same total work, 3x faster execution."
            mark_complete "level2a"
            check_achievements
            read -p "Press Enter to continue..."
            level2
            ;;
        b)
            echo ""
            echo -e "${CYAN}Challenge 2b: Real Work${NC}"
            echo ""
            echo "Check Node.js version on all machines simultaneously:"
            echo ""
            echo -e "${GREEN}./run-on-all.sh \"node --version\"${NC}"
            echo ""
            read -p "Press Enter when ready to run..."
            ./run-on-all.sh "bash -l -c 'node --version'"
            echo ""
            echo -e "${GREEN}✓ All environments checked in parallel!${NC}"
            mark_complete "level2b"
            check_achievements
            read -p "Press Enter to continue..."
            level2
            ;;
        r)
            return
            ;;
    esac
}

# Level 3: Message Bus
level3() {
    clear
    show_banner
    echo -e "${BLUE}━━━ Level 3: Message Bus Coordination ━━━${NC}"
    echo ""
    echo "Machines talking to machines"
    echo ""
    echo "Challenges:"
    echo "  a) Health Check All Buses"
    echo "  b) Send Cross-Machine Message"
    echo "  r) Return to menu"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose challenge: ${NC})" choice

    case $choice in
        a)
            echo ""
            echo -e "${CYAN}Challenge 3a: Health Check All Buses${NC}"
            echo ""
            echo "Check all three message buses:"
            echo ""
            echo -e "${GREEN}./run-on-all.sh \"curl -s http://localhost:3100/health | jq -r '.machine'\"${NC}"
            echo ""
            read -p "Press Enter when ready to run..."
            ./run-on-all.sh "curl -s http://localhost:3100/health | jq -r '.machine'"
            echo ""
            echo -e "${GREEN}✓ All message buses are listening!${NC}"
            mark_complete "level3a"
            check_achievements
            read -p "Press Enter to continue..."
            level3
            ;;
        b)
            echo ""
            echo -e "${CYAN}Challenge 3b: Cross-Machine Messaging${NC}"
            echo ""
            echo "Send a message from maxyolo to pinky's message bus:"
            echo ""
            read -p "Press Enter to send message..."

            curl -X POST http://192.168.5.80:3100/send \
                -H "Content-Type: application/json" \
                -d '{"from":"maxyolo","to":"pinky","body":"Hello from training! 🎮"}'

            echo ""
            echo ""
            echo "Now check messages on pinky's inbox:"
            ssh pinky "curl -s http://localhost:3100/inbox | jq '.messages[] | {from, to, body}'"

            echo ""
            echo -e "${GREEN}✓ Cross-machine communication works!${NC}"
            echo "Machines can leave messages for each other asynchronously."
            mark_complete "level3b"
            check_achievements
            read -p "Press Enter to continue..."
            level3
            ;;
        r)
            return
            ;;
    esac
}

# Level 4: Role-Based Thinking
level4() {
    clear
    show_banner
    echo -e "${BLUE}━━━ Level 4: Role-Based Thinking ━━━${NC}"
    echo ""
    echo "Each machine has a purpose. Learn to delegate wisely."
    echo ""
    echo "Challenges:"
    echo "  a) Assign Roles - Who Does What?"
    echo "  b) Run as Brain (Planner Mode)"
    echo "  c) Run as Pinky (Executor Mode)"
    echo "  r) Return to menu"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose challenge: ${NC})" choice

    case $choice in
        a)
            echo ""
            echo -e "${CYAN}Challenge 4a: Assign Roles${NC}"
            echo ""
            echo "The Three Minds:"
            echo "  🎮 maxyolo = Orchestrator (You - coordinate & decide)"
            echo "  🧠 brain   = Planner (Analyze & strategize)"
            echo "  💖 pinky   = Executor (Build & deliver)"
            echo ""
            echo "Let's verify each machine knows its role:"
            echo ""
            read -p "Press Enter to check roles..."

            echo ""
            echo -e "${YELLOW}Checking ~/pinkyandbrain/prompts/ on all machines...${NC}"
            ./run-on-all.sh "ls -1 ~/pinkyandbrain/prompts/*.md 2>/dev/null || echo 'No role prompts found'"

            echo ""
            echo -e "${GREEN}✓ Role-based thinking unlocked!${NC}"
            echo ""
            echo "Lesson: Don't ask 'what machine?' Ask 'what ROLE?'"
            echo "  Planning? → brain"
            echo "  Execution? → pinky"
            echo "  Coordination? → maxyolo"
            mark_complete "level4a"
            check_achievements
            read -p "Press Enter to continue..."
            level4
            ;;
        b)
            echo ""
            echo -e "${CYAN}Challenge 4b: Run as Brain${NC}"
            echo ""
            echo "Experience the planner role:"
            echo ""
            echo -e "${GREEN}cd ~/pinkyandbrain && ./run-as-brain.sh${NC}"
            echo ""
            echo "This starts brain mode with:"
            echo "  - Strategic planning mindset"
            echo "  - Cloud poller watching for requests"
            echo "  - Role-specific prompt loaded"
            echo ""
            echo "Try it in another terminal window!"
            echo "To stop: pkill -f 'cloud-poller.sh brain'"
            echo ""
            mark_complete "level4b"
            check_achievements
            read -p "Press Enter to continue..."
            level4
            ;;
        c)
            echo ""
            echo -e "${CYAN}Challenge 4c: Run as Pinky${NC}"
            echo ""
            echo "Experience the executor role:"
            echo ""
            echo -e "${GREEN}cd ~/pinkyandbrain && ./run-as-pinky.sh${NC}"
            echo ""
            echo "This starts pinky mode with:"
            echo "  - Implementation focus"
            echo "  - Waiting for brain's plans"
            echo "  - Quality execution mindset"
            echo ""
            echo "Try it in another terminal window!"
            echo "To stop: pkill -f 'cloud-poller.sh pinky'"
            echo ""
            mark_complete "level4c"
            check_achievements
            read -p "Press Enter to continue..."
            level4
            ;;
        r)
            return
            ;;
    esac
}

# Level 5: Real Workflows
level5() {
    clear
    show_banner
    echo -e "${BLUE}━━━ Level 5: Real Workflows ━━━${NC}"
    echo ""
    echo "Put it all together - real autonomous workflows"
    echo ""
    echo "Challenges:"
    echo "  a) Autonomous Workflow Orchestration"
    echo "  b) Monitor the Timeline"
    echo "  c) Share Knowledge Across Machines"
    echo "  r) Return to menu"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose challenge: ${NC})" choice

    case $choice in
        a)
            echo ""
            echo -e "${CYAN}Challenge 5a: Autonomous Workflow${NC}"
            echo ""
            echo "Run a complete end-to-end autonomous workflow:"
            echo ""
            echo -e "${GREEN}./workflow-orchestrator.sh \"Build a hello world component\"${NC}"
            echo ""
            echo "This will:"
            echo "  1. Health check all machines"
            echo "  2. Send request to brain"
            echo "  3. Deploy pollers everywhere"
            echo "  4. Start autonomous agents"
            echo "  5. Monitor until complete"
            echo ""
            read -p "Press Enter to run workflow..."
            ./workflow-orchestrator.sh "Build a hello world component"
            echo ""
            echo -e "${GREEN}✓ Full autonomous workflow complete!${NC}"
            mark_complete "level5a"
            check_achievements
            read -p "Press Enter to continue..."
            level5
            ;;
        b)
            echo ""
            echo -e "${CYAN}Challenge 5b: Monitor the Timeline${NC}"
            echo ""
            echo "View the public timeline showing all activity:"
            echo ""
            echo -e "${GREEN}open https://pinky-brain-timeline.pages.dev${NC}"
            echo ""
            echo "You should see events from your workflow:"
            echo "  - Planning events from brain"
            echo "  - Implementation events from pinky"
            echo "  - Completion events from maxyolo"
            echo ""
            read -p "Press Enter when you've viewed the timeline..."
            echo ""
            echo -e "${GREEN}✓ Timeline visibility unlocked!${NC}"
            echo "Real-time monitoring of autonomous work."
            mark_complete "level5b"
            check_achievements
            read -p "Press Enter to continue..."
            level5
            ;;
        c)
            echo ""
            echo -e "${CYAN}Challenge 5c: Share Knowledge${NC}"
            echo ""
            echo "Teach the team something you learned:"
            echo ""
            echo -e "${GREEN}./knowledge-cli.sh${NC}"
            echo ""
            echo "This will guide you through sharing knowledge:"
            echo "  - What did you learn?"
            echo "  - Code examples"
            echo "  - Tags for searchability"
            echo ""
            read -p "Press Enter to share knowledge..."
            ./knowledge-cli.sh
            echo ""
            echo -e "${GREEN}✓ Knowledge shared! The team learns together.${NC}"
            mark_complete "level5c"
            check_achievements
            read -p "Press Enter to continue..."
            level5
            ;;
        r)
            return
            ;;
    esac
}

# Level 6: Cloud & Timeline
level6() {
    clear
    show_banner
    echo -e "${BLUE}━━━ Level 6: Cloud Bus & Timeline ━━━${NC}"
    echo ""
    echo "Master cloud coordination and public timelines"
    echo ""
    echo "Challenges:"
    echo "  a) Check Cloud Bus Status"
    echo "  b) Post Timeline Event"
    echo "  c) Query Shared Knowledge"
    echo "  r) Return to menu"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose challenge: ${NC})" choice

    case $choice in
        a)
            echo ""
            echo -e "${CYAN}Challenge 6a: Cloud Bus Status${NC}"
            echo ""
            echo "Check the cloud message bus:"
            echo ""
            read -p "Press Enter to check..."
            curl -s https://pinky-brain-hub.b-9f2.workers.dev/health | jq .
            echo ""
            echo "Check pending messages:"
            curl -s "https://pinky-brain-hub.b-9f2.workers.dev/messages?for=maxyolo" \
                -H "X-API-Key: 3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5" | jq .
            echo ""
            echo -e "${GREEN}✓ Cloud bus operational!${NC}"
            mark_complete "level6a"
            check_achievements
            read -p "Press Enter to continue..."
            level6
            ;;
        b)
            echo ""
            echo -e "${CYAN}Challenge 6b: Post Timeline Event${NC}"
            echo ""
            echo "Post an event to the public timeline:"
            echo ""
            read -p "Press Enter to post..."
            curl -X POST https://pinky-brain-hub.b-9f2.workers.dev/timeline \
                -H "Content-Type: application/json" \
                -H "X-API-Key: 3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5" \
                -d '{
                    "machine": "maxyolo",
                    "event_type": "training",
                    "title": "Completed Level 6 Training",
                    "description": "Human learned cloud coordination! 🎓"
                }' | jq .
            echo ""
            echo "View it at: https://pinky-brain-timeline.pages.dev"
            echo ""
            echo -e "${GREEN}✓ Timeline event posted!${NC}"
            mark_complete "level6b"
            check_achievements
            read -p "Press Enter to continue..."
            level6
            ;;
        c)
            echo ""
            echo -e "${CYAN}Challenge 6c: Query Knowledge Base${NC}"
            echo ""
            echo "Search the shared knowledge:"
            echo ""
            read -p "Press Enter to search..."
            curl -s "https://pinky-brain-hub.b-9f2.workers.dev/knowledge?limit=5" | jq '.entries[] | {topic, title, from: .from_machine}'
            echo ""
            echo -e "${GREEN}✓ Knowledge base accessed!${NC}"
            echo "The team's collective learning is available to all."
            mark_complete "level6c"
            check_achievements
            read -p "Press Enter to continue..."
            level6
            ;;
        r)
            return
            ;;
    esac
}

# Level 8: Team Communication
level8() {
    clear
    show_banner
    echo -e "${BLUE}━━━ Level 8: Team Communication ━━━${NC}"
    echo ""
    echo "Master async communication across machines"
    echo ""
    echo "Challenges:"
    echo "  a) Send Good Morning"
    echo "  b) Check Messages"
    echo "  c) Morning Routine"
    echo "  r) Return to menu"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose challenge: ${NC})" choice

    case $choice in
        a)
            echo ""
            echo -e "${CYAN}Challenge 8a: Send Good Morning${NC}"
            echo ""
            echo "Say GM to all machines:"
            echo ""
            echo -e "${GREEN}./gm.sh send${NC}"
            echo ""
            read -p "Press Enter to send GM..."
            ./gm.sh send
            echo ""
            echo -e "${GREEN}✓ GM sent to the team!${NC}"
            echo ""
            echo "Your machines now know you're online and ready."
            mark_complete "level8a"
            check_achievements
            read -p "Press Enter to continue..."
            level8
            ;;
        b)
            echo ""
            echo -e "${CYAN}Challenge 8b: Check Messages${NC}"
            echo ""
            echo "See who said GM to you:"
            echo ""
            echo -e "${GREEN}./gm.sh receive${NC}"
            echo ""
            read -p "Press Enter to check messages..."
            ./gm.sh receive
            echo ""
            echo -e "${GREEN}✓ You're connected to the team!${NC}"
            mark_complete "level8b"
            check_achievements
            read -p "Press Enter to continue..."
            level8
            ;;
        c)
            echo ""
            echo -e "${CYAN}Challenge 8c: Morning Routine${NC}"
            echo ""
            echo "Complete the full morning startup:"
            echo ""
            echo "1. Say GM"
            ./gm.sh send
            echo ""
            echo "2. Check who's online"
            ./gm.sh receive
            echo ""
            echo "3. Check GitHub (if you have repos)"
            echo -e "${YELLOW}(Skipping gh issue list - run manually if needed)${NC}"
            echo ""
            echo -e "${GREEN}✓ Morning routine complete!${NC}"
            echo ""
            echo "Daily rituals like this:"
            echo "  - Build team awareness"
            echo "  - Create connection across machines"
            echo "  - Compound over time"
            mark_complete "level8c"
            check_achievements
            read -p "Press Enter to continue..."
            level8
            ;;
        r)
            return
            ;;
    esac
}

# Main menu loop
main() {
    while true; do
        show_banner
        show_menu

        case $choice in
            1) level1 ;;
            2) level2 ;;
            3) level3 ;;
            4) level4 ;;
            5) level5 ;;
            6) level6 ;;
            7) level8 ;;
            8)
                echo "Master challenges are in TRAIN-THE-HUMAN.md"
                echo "Create your own distributed systems!"
                read -p "Press Enter to continue..."
                ;;
            p) show_progress ;;
            q)
                echo ""
                echo "Keep thinking in parallel! 🧠⚡"
                exit 0
                ;;
            *)
                echo "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

# Run main menu
main
