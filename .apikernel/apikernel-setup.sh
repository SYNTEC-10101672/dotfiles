#!/bin/bash
# ============================================
# Apikernel Setup Script
# Mount Samba share + Run SetupSDK.bat
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

# Auto-detect local IP address for Samba server (use default route interface)
SAMBA_SERVER=$(ip route get 1 | awk '{print $7; exit}')

# Fallback for APIKERNEL_BUILD_DIR
BUILD_DIR="${APIKERNEL_BUILD_DIR:-$HOME/project/windows_project/apikernel/Build}"

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
echo -e "${BLUE}Apikernel Setup${NC}"
echo -e "${BLUE}Mount + SetupSDK${NC}"
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

# Check if Build directory exists locally
echo -e "${YELLOW}[2/3] Verifying Build directory...${NC}"
if [ ! -d "${BUILD_DIR}" ]; then
    echo -e "${RED}ERROR: Build directory not found${NC}"
    echo "Expected: ${BUILD_DIR}"
    echo ""
    echo "Set APIKERNEL_BUILD_DIR in ~/.env:"
    echo "  export APIKERNEL_BUILD_DIR=\"\${HOME}/project/windows_project/apikernel/Build\""
    exit 1
fi
echo -e "${GREEN}✓ Build directory exists: ${BUILD_DIR}${NC}"
echo ""

# Execute remote setup via SSH with timeout (SetupSDK.bat involves multiple downloads)
echo -e "${YELLOW}[3/3] Connecting to Windows PC...${NC}"
echo -e "${BLUE}Mounting share and running SetupSDK.bat (this may take several minutes)...${NC}"
echo ""

timeout 600 sshpass -p "${WINDOWS_PASSWORD}" ssh -t -o StrictHostKeyChecking=no ${WINDOWS_HOST} << ENDSSH
@echo off
chcp 65001 >nul 2>&1
:: Enable ANSI color support
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
echo [1/3] Mounting Samba share to Z:...
net use Z: /delete /y >nul 2>&1
net use Z: \\\\${SAMBA_SERVER}\\sharedfolder "${SAMBA_PASSWORD}" /user:${SAMBA_USER} /persistent:no
if errorlevel 1 (
    echo ERROR: Failed to mount Samba share
    exit /b 1
)
echo Successfully mounted to Z:

echo [2/3] Navigating to apikernel Build...
cd /d Z:\apikernel\Build
if errorlevel 1 (
    echo ERROR: Failed to navigate to Z:\apikernel\Build
    exit /b 1
)

echo [3/3] Running SetupSDK.bat...
call SetupSDK.bat
if errorlevel 1 (
    echo ERROR: SetupSDK.bat failed
    exit /b 1
)

echo SetupSDK completed!
ENDSSH

SETUP_RESULT=$?

echo ""
if [ $SETUP_RESULT -eq 0 ]; then
    # Post-check: verify OCSDK directory structure
    OCSDK_INC="${BUILD_DIR}/../OCSDK/inc"
    OCSDK_LIB="${BUILD_DIR}/../OCSDK/lib"

    if [ -d "${OCSDK_INC}" ] && [ -d "${OCSDK_LIB}" ]; then
        echo -e "${GREEN}=====================================${NC}"
        echo -e "${GREEN}SETUP COMPLETED!${NC}"
        echo -e "${GREEN}=====================================${NC}"
        echo ""
        echo "✓ Samba share mounted (temporary)"
        echo "✓ SetupSDK.bat executed"
        echo "✓ OCSDK/inc/ exists: ${OCSDK_INC}"
        echo "✓ OCSDK/lib/ exists: ${OCSDK_LIB}"
        echo ""
        echo "Next step: Run 'apikbuild <PLATFORM> <CONFIG>' to cross-compile"
    else
        echo -e "${RED}=====================================${NC}"
        echo -e "${RED}SETUP FAILED${NC}"
        echo -e "${RED}=====================================${NC}"
        echo ""
        echo "SetupSDK.bat exited OK but OCSDK directory structure is incomplete:"
        [ ! -d "${OCSDK_INC}" ] && echo "  ✗ Missing: ${OCSDK_INC}"
        [ ! -d "${OCSDK_LIB}" ] && echo "  ✗ Missing: ${OCSDK_LIB}"
        echo ""
        echo "Please check SetupSDK.bat output for errors."
        exit 1
    fi
elif [ $SETUP_RESULT -eq 124 ]; then
    echo -e "${RED}=====================================${NC}"
    echo -e "${RED}SETUP FAILED (timeout)${NC}"
    echo -e "${RED}=====================================${NC}"
    echo ""
    echo "SSH session timed out after 600 seconds."
    echo "SetupSDK.bat may still be running on the Windows PC."
    exit 1
else
    echo -e "${RED}=====================================${NC}"
    echo -e "${RED}SETUP FAILED${NC}"
    echo -e "${RED}=====================================${NC}"
    echo ""
    echo "SSH session exited with code: ${SETUP_RESULT}"
    exit 1
fi
