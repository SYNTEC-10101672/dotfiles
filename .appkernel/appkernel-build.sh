#!/bin/bash
# ============================================
# Appkernel Build Script
# Build any appkernel project
# Usage: akbuild <PROJECT> <CONFIG>
#   PROJECT: Project name (e.g., MMICommon32, CncMonEL)
#   CONFIG: Configuration (e.g., ReleaseEL, DebugEL)
# Examples:
#   akbuild MMICommon32 ReleaseEL
#   akbuild CncMonEL ReleaseEL
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check parameters
if [ $# -lt 2 ]; then
    echo -e "${RED}ERROR: Missing required parameters${NC}"
    echo ""
    echo "Usage: akbuild <PROJECT> <CONFIG>"
    echo ""
    echo "Examples:"
    echo "  akbuild MMICommon32 ReleaseEL"
    echo "  akbuild CncMonEL ReleaseEL"
    echo "  akbuild CncMon DebugEL"
    echo ""
    exit 1
fi

# Get parameters
BUILD_TARGET="$1:Rebuild"
BUILD_CONFIG="$2"

# Configuration (read from environment variables)
WINDOWS_HOST="${APPKERNEL_WINDOWS_HOST}"
WINDOWS_PASSWORD="${APPKERNEL_WINDOWS_PASSWORD}"
SAMBA_USER="${APPKERNEL_SAMBA_USER}"
SAMBA_PASSWORD="${APPKERNEL_SAMBA_PASSWORD}"

# Auto-detect local IP address for Samba server (use default route interface)
SAMBA_SERVER=$(ip route get 1 | awk '{print $7; exit}')

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
echo -e "${BLUE}Appkernel Build${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${BLUE}Project: ${1}${NC}"
echo -e "${BLUE}Config:  ${2}${NC}"
echo -e "${BLUE}Target:  ${BUILD_TARGET}${NC}"
echo ""

# Execute remote build
echo -e "${YELLOW}Connecting to Windows PC and building...${NC}"
echo ""

# Use sshpass to automatically provide password
# Mount share and build in one session
# Enable color output with -t flag
sshpass -p "${WINDOWS_PASSWORD}" ssh -t -o StrictHostKeyChecking=no ${WINDOWS_HOST} << ENDSSH
@echo off
chcp 65001 >nul 2>&1
:: Enable ANSI color support
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
echo [1/4] Mounting Z: drive...
net use Z: /delete /y >nul 2>&1
net use Z: \\\\${SAMBA_SERVER}\\sharedfolder "${SAMBA_PASSWORD}" /user:${SAMBA_USER} /persistent:no
if errorlevel 1 (
    echo ERROR: Failed to mount Z:
    exit /b 1
)
echo Successfully mounted to Z:

echo [2/4] Navigating to appkernel...
cd /d Z:\\appkernel
if errorlevel 1 (
    echo ERROR: Failed to navigate to Z:\\appkernel
    exit /b 1
)

echo [3/4] Setting up build environment...
set MSBUILD="C:\\Program Files\\Microsoft Visual Studio\\2022\\Professional\\MSBuild\\Current\\Bin\\MSBuild.exe"
echo MSBUILD: %MSBUILD%

echo [4/4] Building ${1} (${2})...
%MSBUILD% Appkernel32.sln /r /p:RestorePackagesConfig=true /t:${BUILD_TARGET} /property:Configuration=${BUILD_CONFIG} /nodeReuse:False /consoleloggerparameters:ForceConsoleColor
if errorlevel 1 (
    echo.
    echo BUILD FAILED!
    exit /b 1
)
echo.
echo BUILD SUCCESS!
ENDSSH

BUILD_RESULT=$?

echo ""
if [ $BUILD_RESULT -eq 0 ]; then
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}BUILD SUCCESS${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo -e "Project: ${BLUE}${1}${NC}"
    echo -e "Config:  ${BLUE}${2}${NC}"
    echo -e "Output:  ${BLUE}~/project/windows_project/appkernel/${NC}"
else
    echo -e "${RED}=====================================${NC}"
    echo -e "${RED}BUILD FAILED${NC}"
    echo -e "${RED}=====================================${NC}"
    echo ""
    echo -e "Project: ${1}"
    echo -e "Config:  ${2}"
    echo ""
    echo "If SDK not loaded, run 'aksetup' first"
    exit 1
fi
