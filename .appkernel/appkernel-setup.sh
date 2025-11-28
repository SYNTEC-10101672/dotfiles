#!/bin/bash
# ============================================
# Appkernel Setup Script
# Mount Samba share + Load SDK
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration (read from environment variables)
WINDOWS_HOST="${APPKERNEL_WINDOWS_HOST}"
WINDOWS_PASSWORD="${APPKERNEL_WINDOWS_PASSWORD}"
SAMBA_USER="${APPKERNEL_SAMBA_USER}"
SAMBA_PASSWORD="${APPKERNEL_SAMBA_PASSWORD}"

# Auto-detect local IP address for Samba server
SAMBA_SERVER=$(hostname -I | awk '{print $1}')

# Check if all required environment variables are set
if [ -z "$WINDOWS_HOST" ]; then
    echo -e "${RED}ERROR: APPKERNEL_WINDOWS_HOST not set${NC}"
    echo "Please set it in ~/.env"
    exit 1
fi

if [ -z "$WINDOWS_PASSWORD" ]; then
    echo -e "${RED}ERROR: APPKERNEL_WINDOWS_PASSWORD not set${NC}"
    echo "Please set it in ~/.env"
    exit 1
fi

if [ -z "$SAMBA_USER" ]; then
    echo -e "${RED}ERROR: APPKERNEL_SAMBA_USER not set${NC}"
    echo "Please set it in ~/.env"
    exit 1
fi

if [ -z "$SAMBA_PASSWORD" ]; then
    echo -e "${RED}ERROR: APPKERNEL_SAMBA_PASSWORD not set${NC}"
    echo "Please set it in ~/.env"
    exit 1
fi

if [ -z "$SAMBA_SERVER" ]; then
    echo -e "${RED}ERROR: Failed to detect local IP address${NC}"
    echo "Please check network configuration"
    exit 1
fi

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Appkernel Setup${NC}"
echo -e "${BLUE}Mount + Load SDK${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check if Samba is running
echo -e "${YELLOW}[1/3] Checking Samba service...${NC}"
if ! systemctl is-active --quiet smbd; then
    echo -e "${RED}ERROR: Samba service is not running${NC}"
    echo "Please start Samba: sudo systemctl start smbd"
    exit 1
fi
echo -e "${GREEN}✓ Samba service is running${NC}"
echo ""

# Check if project directory exists
echo -e "${YELLOW}[2/2] Verifying project directory...${NC}"
if [ ! -d "$HOME/project/windows_project/appkernel" ]; then
    echo -e "${RED}ERROR: Project directory not found${NC}"
    echo "Expected: $HOME/project/windows_project/appkernel"
    exit 1
fi
echo -e "${GREEN}✓ Project directory exists${NC}"
echo ""

# Execute remote setup
echo -e "${YELLOW}Connecting to Windows PC...${NC}"
echo -e "${BLUE}Mounting share and loading SDK (this may take several minutes)...${NC}"
echo ""

# Use sshpass to automatically provide password
# Execute commands directly instead of running a batch file
# Enable color output with -t flag
sshpass -p "${WINDOWS_PASSWORD}" ssh -t -o StrictHostKeyChecking=no ${WINDOWS_HOST} << ENDSSH
@echo off
chcp 65001 >nul 2>&1
:: Enable ANSI color support
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
echo [1/3] Mounting Samba share to Z:...
net use Z: /delete /y >nul 2>&1
net use Z: \\\\${SAMBA_SERVER}\\sharedfolder "${SAMBA_PASSWORD}" /user:${SAMBA_USER} /persistent:yes
if errorlevel 1 (
    echo ERROR: Failed to mount Samba share
    exit /b 1
)
echo Successfully mounted to Z:

echo [2/3] Navigating to appkernel...
cd /d Z:\appkernel
if errorlevel 1 (
    echo ERROR: Failed to navigate to Z:\appkernel
    exit /b 1
)

echo [3/3] Loading SDK environment...
pushd Debug
call MMIDebugEnv.bat
popd

echo Setup completed!
ENDSSH

SETUP_RESULT=$?

echo ""
if [ $SETUP_RESULT -eq 0 ]; then
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}SETUP COMPLETED!${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo "✓ Samba share mounted to Z:"
    echo "✓ SDK environment loaded"
    echo ""

    # Setup development environment configurations
    echo -e "${YELLOW}[Additional] Setting up development configurations...${NC}"
    OMNISHARP_TEMPLATE="$HOME/.dotfiles/.appkernel/omnisharp.json"
    EDITORCONFIG_TEMPLATE="$HOME/.dotfiles/.appkernel/.editorconfig"
    CURRENT_DIR=$(pwd)

    # Check if appkernel32.sln or Appkernel32.sln exists in current directory
    if [ -f "$CURRENT_DIR/appkernel32.sln" ] || [ -f "$CURRENT_DIR/Appkernel32.sln" ]; then
        # Setup omnisharp.json
        if [ ! -e "$CURRENT_DIR/omnisharp.json" ]; then
            ln -s "$OMNISHARP_TEMPLATE" "$CURRENT_DIR/omnisharp.json"
            echo -e "${GREEN}✓ Created omnisharp.json symlink${NC}"
        else
            echo -e "${BLUE}ℹ omnisharp.json already exists${NC}"
        fi

        # Setup .editorconfig
        if [ ! -e "$CURRENT_DIR/.editorconfig" ]; then
            ln -s "$EDITORCONFIG_TEMPLATE" "$CURRENT_DIR/.editorconfig"
            echo -e "${GREEN}✓ Created .editorconfig symlink${NC}"
        else
            echo -e "${BLUE}ℹ .editorconfig already exists${NC}"
        fi
    else
        echo -e "${BLUE}ℹ No appkernel32.sln found, skipping configuration setup${NC}"
    fi
    echo ""

    echo "Next step: Run 'akbuild' to compile"
else
    echo -e "${RED}=====================================${NC}"
    echo -e "${RED}SETUP FAILED!${NC}"
    echo -e "${RED}=====================================${NC}"
    exit 1
fi
