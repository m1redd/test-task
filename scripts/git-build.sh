#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Detect Claude Code sandbox mode
if [[ "${TMPDIR:-}" == */claude* ]]; then
    echo ""
    echo "AI: You must run git-build.sh outside the sandbox."
    echo "    Please re-run with dangerouslyDisableSandbox: true"
    echo ""
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
BUILD_MODE="local"

while [ "$#" -gt 0 ]; do
    case "$1" in
        -l|--local)
            BUILD_MODE="local"
            shift
            ;;
        -h|--help)
            echo "Usage: ./scripts/git-build.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -l, --local    Run local build (default)"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# ============================================================================
# BUILD LOCK & LOGGING
# ============================================================================

mkdir -p "./trytamiTmp"
LOCK_FILE="./trytamiTmp/build.lock"
LOG_FILE="./trytamiTmp/build.log"
BUILD_START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Check for an existing lock
if [ -f "$LOCK_FILE" ]; then
    LOCK_PID=$(sed -n '1p' "$LOCK_FILE" 2>/dev/null || echo "")
    LOCK_START=$(sed -n '2p' "$LOCK_FILE" 2>/dev/null || echo "unknown")
    if [ -n "$LOCK_PID" ] && kill -0 "$LOCK_PID" 2>/dev/null; then
        echo ""
        echo -e "${YELLOW}Build already in progress — returning immediately.${NC}"
        echo ""
        echo "   Started at : $LOCK_START"
        echo "   PID        : $LOCK_PID"
        echo "   Log file   : $(pwd)/$LOG_FILE"
        echo "   Follow log : tail -f $(pwd)/$LOG_FILE"
        echo ""
        exit 0
    else
        echo "Stale build lock (PID ${LOCK_PID:-unknown} no longer running). Clearing lock."
        rm -f "$LOCK_FILE"
    fi
fi

# Acquire lock
printf '%s\n%s\n' "$$" "$BUILD_START" > "$LOCK_FILE"

# Redirect all output to log file while keeping stdout/stderr visible
BUILD_FIFO="trytamiTmp/build-fifo"
rm -f "$BUILD_FIFO"
mkfifo "$BUILD_FIFO"
tee "$LOG_FILE" < "$BUILD_FIFO" &
TEE_PID=$!
exec > "$BUILD_FIFO" 2>&1
trap 'rm -f "$LOCK_FILE" "$BUILD_FIFO"; kill $TEE_PID 2>/dev/null || true' EXIT

echo "[BUILD] Log file : $(pwd)/$LOG_FILE"
echo "[BUILD] Started  : $BUILD_START"
echo "[BUILD] PID      : $$"
echo ""

# Function to print step headers
print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to handle errors
handle_error() {
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}BUILD FAILED: $1${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    exit 1
}

# ============================================================================
# LOCAL BUILD VALIDATION
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}LOCAL BUILD VALIDATION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 0: Verify node_modules exists
print_step "Step 0: Verifying node_modules"

if [ ! -d "node_modules" ]; then
    echo -e "${RED}node_modules not found${NC}"
    echo -e "${YELLOW}   Run 'npm install' to install dependencies.${NC}"
    handle_error "node_modules not found - run 'npm install'"
fi

if [ "package.json" -nt "node_modules/.package-lock.json" ] 2>/dev/null; then
    echo -e "${YELLOW}package.json is newer than node_modules — consider running 'npm install'${NC}"
fi

echo -e "${GREEN}node_modules exists${NC}"

# Step 1: TypeScript compilation check
print_step "Step 1: TypeScript type-checking"
npx tsc --noEmit || handle_error "TypeScript compilation failed"
echo -e "${GREEN}TypeScript type-check passed${NC}"

# Step 2: ESLint
print_step "Step 2: Linting (ESLint)"
npx eslint 'src/**/*.ts' || handle_error "Linting failed"
echo -e "${GREEN}Linting passed${NC}"

# Step 3: Prettier format check
print_step "Step 3: Format check (Prettier)"
npx prettier --check 'src/**/*.ts' || handle_error "Format check failed — run 'npm run format'"
echo -e "${GREEN}Format check passed${NC}"

# Step 4: Tests
print_step "Step 4: Running tests"
npx jest --passWithNoTests || handle_error "Tests failed"
echo -e "${GREEN}Tests passed${NC}"

# Success!
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}ALL CHECKS PASSED!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Your code is ready!${NC}"
echo ""
