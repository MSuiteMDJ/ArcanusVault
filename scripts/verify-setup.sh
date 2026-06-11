#!/bin/bash
# AV Vault OS - Pre-Build Verification Checklist

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERRORS=0
WARNINGS=0

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔍 AV Vault OS - Pre-Build Verification"
echo "========================================"
echo ""

# Function to print status
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

# 1. Check repository structure
echo "📁 Repository Structure"
echo "---------------------"

if [ -d "$PROJECT_ROOT/.github/workflows" ]; then
    check_pass "GitHub Actions directory exists"
else
    check_fail ".github/workflows directory missing"
fi

if [ -f "$PROJECT_ROOT/.github/workflows/build-image.yml" ]; then
    check_pass "Build workflow file exists"
else
    check_fail "build-image.yml not found"
fi

if [ -d "$PROJECT_ROOT/build" ]; then
    check_pass "build/ directory exists"
else
    check_fail "build/ directory missing"
fi

if [ -f "$PROJECT_ROOT/build/armbian-build.sh" ]; then
    check_pass "Main build script exists"
else
    check_fail "armbian-build.sh not found"
fi

if [ -f "$PROJECT_ROOT/build/build-locally.sh" ]; then
    check_pass "Local build wrapper exists"
else
    check_fail "build-locally.sh not found"
fi

echo ""

# 2. Check branding overlay
echo "🎨 Branding Overlay"
echo "------------------"

if [ -d "$PROJECT_ROOT/branding/rootfs" ]; then
    check_pass "Branding overlay directory exists"
    
    if [ -f "$PROJECT_ROOT/branding/rootfs/etc/hostname" ]; then
        check_pass "Hostname file present"
        HOSTNAME_VAL=$(cat "$PROJECT_ROOT/branding/rootfs/etc/hostname")
        [ "$HOSTNAME_VAL" = "av-vault" ] && check_pass "Hostname is 'av-vault'" || check_warn "Hostname is '$HOSTNAME_VAL' (expected 'av-vault')"
    else
        check_warn "etc/hostname not found"
    fi
    
    if [ -f "$PROJECT_ROOT/branding/rootfs/etc/motd" ]; then
        check_pass "MOTD file present"
    else
        check_warn "etc/motd not found"
    fi
    
    if [ -f "$PROJECT_ROOT/branding/rootfs/etc/issue" ]; then
        check_pass "Issue banner file present"
    else
        check_warn "etc/issue not found"
    fi
else
    check_fail "branding/rootfs directory missing"
fi

echo ""

# 3. Check documentation
echo "📚 Documentation"
echo "---------------"

docs=(
    "docs/BUILD.md"
    "docs/BUILD_PHASES.md"
    "docs/BUILD_ENVIRONMENT.md"
    "docs/CI-CD.md"
    "QUICKSTART.md"
    "README.md"
)

for doc in "${docs[@]}"; do
    if [ -f "$PROJECT_ROOT/$doc" ]; then
        check_pass "$doc exists"
    else
        check_warn "$doc missing"
    fi
done

echo ""

# 4. Check script permissions
echo "⚙️  Script Permissions"
echo "--------------------"

scripts=(
    "build/armbian-build.sh"
    "build/build-locally.sh"
)

for script in "${scripts[@]}"; do
    script_path="$PROJECT_ROOT/$script"
    if [ -f "$script_path" ]; then
        if [ -x "$script_path" ]; then
            check_pass "$script is executable"
        else
            check_warn "$script is not executable (run: chmod +x $script_path)"
        fi
    fi
done

echo ""

# 5. Check configuration
echo "⚙️  Build Configuration"
echo "---------------------"

if [ -f "$PROJECT_ROOT/build/config/armbian-config.sh" ]; then
    check_pass "Build config file exists"
    
    # Check for required variables
    if grep -q "BOARD=" "$PROJECT_ROOT/build/config/armbian-config.sh"; then
        check_pass "BOARD variable defined"
    else
        check_warn "BOARD variable not defined"
    fi
    
    if grep -q "RELEASE=" "$PROJECT_ROOT/build/config/armbian-config.sh"; then
        check_pass "RELEASE variable defined"
    else
        check_warn "RELEASE variable not defined"
    fi
else
    check_fail "armbian-config.sh not found"
fi

if [ -f "$PROJECT_ROOT/Makefile" ]; then
    check_pass "Makefile exists"
else
    check_warn "Makefile missing"
fi

echo ""

# 6. Check git status
echo "🔗 Git Repository"
echo "----------------"

if [ -d "$PROJECT_ROOT/.git" ]; then
    check_pass "Git repository initialized"
    
    cd "$PROJECT_ROOT"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        check_pass "Git repository is valid"
        
        # Check if there's a remote
        if git remote -v | grep -q "origin"; then
            remote_url=$(git remote get-url origin)
            check_pass "Remote 'origin' configured: $(echo $remote_url | cut -c1-50)..."
        else
            check_warn "No 'origin' remote configured"
        fi
        
        # Check main branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        [ "$current_branch" = "main" ] && check_pass "On 'main' branch" || check_warn "Not on 'main' branch (on: $current_branch)"
    else
        check_fail "Git repository is invalid"
    fi
else
    check_warn "Not a git repository (needed for CI/CD)"
fi

echo ""

# 7. System checks (if not on macOS)
echo "🖥️  System Checks"
echo "---------------"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux system detected - checking build prerequisites..."
    
    tools=("git" "wget" "bc" "make")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            check_pass "$tool is installed"
        else
            check_warn "$tool not found (needed for local builds)"
        fi
    done
    
    # Check disk space
    available=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
    available_gb=$((available / 1024 / 1024))
    if [ "$available_gb" -gt 50 ]; then
        check_pass "Sufficient disk space ($available_gb GB available)"
    else
        check_warn "Low disk space ($available_gb GB available, 50GB recommended)"
    fi
else
    check_pass "macOS detected (GitHub Actions recommended for build)"
fi

echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Pre-build verification passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Address $WARNINGS warning(s) before building${NC}"
    fi
    echo ""
    echo "Next steps:"
    echo "  1. Push to main branch to trigger GitHub Actions"
    echo "  2. Or run: ./build/build-locally.sh (Linux/Ubuntu only)"
    echo "  3. Or run: make build"
    exit 0
else
    echo -e "${RED}✗ Pre-build verification failed!${NC}"
    echo "Please fix the above errors before building"
    exit 1
fi
