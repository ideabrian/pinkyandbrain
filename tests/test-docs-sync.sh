#!/bin/bash
# Test docs sync functionality

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

echo "🧪 Testing Docs Sync System"
echo "============================"

# Test 1: Git repo exists
echo ""
echo "Test 1: Git repository initialized"
cd ~/pinkyandbrain 2>/dev/null
if [ -d .git ]; then
    test_result 0 "Git repo exists at ~/pinkyandbrain"
else
    test_result 1 "Git repo not found"
fi

# Test 2: Remote configured
echo ""
echo "Test 2: GitHub remote configured"
REMOTE=$(git remote get-url origin 2>/dev/null)
if [[ "$REMOTE" == *"ideabrian/pinkyandbrain"* ]]; then
    test_result 0 "Remote URL: $REMOTE"
else
    test_result 1 "Remote not configured correctly"
fi

# Test 3: Docs directory exists
echo ""
echo "Test 3: Docs directory exists"
if [ -d ~/pinkyandbrain/docs ]; then
    test_result 0 "docs/ directory exists"
    echo "   Files: $(ls ~/pinkyandbrain/docs | tr '\n' ', ')"
else
    test_result 1 "docs/ directory missing"
fi

# Test 4: Required docs exist
echo ""
echo "Test 4: Required documentation files"
REQUIRED_DOCS=("HOW-TO-SEND-A-MESSAGE.md" "README.md" "GIT-SETUP.md")
for doc in "${REQUIRED_DOCS[@]}"; do
    if [ -f ~/pinkyandbrain/docs/$doc ]; then
        test_result 0 "$doc exists"
    else
        test_result 1 "$doc missing"
    fi
done

# Test 5: Auto-sync script exists and is executable
echo ""
echo "Test 5: Auto-sync script"
if [ -x ~/pinkyandbrain/scripts/auto-sync-docs.sh ]; then
    test_result 0 "auto-sync-docs.sh is executable"
else
    test_result 1 "auto-sync-docs.sh not executable"
fi

# Test 6: Git status clean (no uncommitted changes in docs/)
echo ""
echo "Test 6: Git status clean"
cd ~/pinkyandbrain
git diff --quiet docs/ 2>/dev/null
if [ $? -eq 0 ]; then
    test_result 0 "No uncommitted changes in docs/"
else
    test_result 1 "Uncommitted changes detected"
    echo "   Run: cd ~/pinkyandbrain && git status"
fi

# Test 7: Can fetch from remote
echo ""
echo "Test 7: GitHub connectivity"
git fetch --dry-run 2>&1 | grep -q "fatal"
if [ $? -ne 0 ]; then
    test_result 0 "Can connect to GitHub"
else
    test_result 1 "Cannot connect to GitHub"
fi

# Test 8: .gitignore properly excludes logs
echo ""
echo "Test 8: .gitignore configuration"
if git check-ignore -q *.log 2>/dev/null; then
    test_result 0 ".gitignore excludes *.log files"
else
    test_result 1 ".gitignore not configured correctly"
fi

# Summary
echo ""
echo "============================"
echo "Test Summary"
echo "============================"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ All tests passed! Docs sync is working.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Check output above.${NC}"
    exit 1
fi
