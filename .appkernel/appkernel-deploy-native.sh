#!/bin/bash
# ============================================
# Appkernel Native Deploy Script
# Deploy compiled native artifacts to CNC controller
# Usage: akndeploy <PROJECT> <PLATFORM> <CONFIG>
#   PROJECT: Project name (e.g., OCUser)
#   PLATFORM: Linux_iMX8MP_A53 | Linux_AM625_A53
#   CONFIG: Debug | Release
# Examples:
#   akndeploy OCUser Linux_iMX8MP_A53 Release
#   akndeploy OCUser Linux_AM625_A53 Debug
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check parameters
if [ $# -lt 3 ]; then
    echo -e "${RED}ERROR: Missing required parameters${NC}"
    echo ""
    echo "Usage: akndeploy <PROJECT> <PLATFORM> <CONFIG>"
    echo ""
    echo "Parameters:"
    echo "  PROJECT:  OCUser"
    echo "  PLATFORM: Linux_iMX8MP_A53 | Linux_AM625_A53"
    echo "  CONFIG:   Debug | Release"
    echo ""
    echo "Examples:"
    echo "  akndeploy OCUser Linux_iMX8MP_A53 Release"
    echo "  akndeploy OCUser Linux_AM625_A53 Debug"
    echo ""
    exit 1
fi

# Get parameters
PROJECT="$1"
PLATFORM="$2"
CONFIG="$3"

# CNC controller configuration (from ~/.ssh/config)
CNC_HOST="${CNC_HOST:-cnc}"

# Validate project
if [ "${PROJECT}" != "OCUser" ]; then
    echo -e "${RED}ERROR: Unsupported project '${PROJECT}'${NC}"
    echo ""
    echo "Currently supported projects:"
    echo "  - OCUser"
    echo ""
    exit 1
fi

# Validate platform
case "${PLATFORM}" in
    Linux_iMX8MP_A53|Linux_AM625_A53)
        # Valid platform
        ;;
    *)
        echo -e "${RED}ERROR: Unsupported platform '${PLATFORM}'${NC}"
        echo ""
        echo "Supported platforms:"
        echo "  - Linux_iMX8MP_A53"
        echo "  - Linux_AM625_A53"
        echo ""
        exit 1
        ;;
esac

# Validate config
case "${CONFIG}" in
    Debug|Release)
        # Valid config
        ;;
    *)
        echo -e "${RED}ERROR: Unsupported config '${CONFIG}'${NC}"
        echo ""
        echo "Supported configs:"
        echo "  - Debug"
        echo "  - Release"
        echo ""
        exit 1
        ;;
esac

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Appkernel Native Deploy${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${BLUE}Project:  ${PROJECT}${NC}"
echo -e "${BLUE}Platform: ${PLATFORM}${NC}"
echo -e "${BLUE}Config:   ${CONFIG}${NC}"
echo -e "${BLUE}Target:   ${CNC_HOST}${NC}"
echo ""

# Fallback defaults (env var override still works)
OCUSER_SOURCE_DIR="${OCUSER_SOURCE_DIR:-$HOME/project/windows_project/appkernel/OCUser/Source}"
CNC_NATIVE_LIB_PATH="${CNC_NATIVE_LIB_PATH:-/DiskC/OpenCNC/Bin}"

# Check required environment variables
if [ ! -d "${OCUSER_SOURCE_DIR}" ]; then
    echo -e "${RED}ERROR: OCUser source directory not found${NC}"
    echo "Path: ${OCUSER_SOURCE_DIR}"
    exit 1
fi

# Step 1: Locate build artifact
echo -e "${YELLOW}[1/3] Locating build artifact...${NC}"

OUTPUT_DIR="${OCUSER_SOURCE_DIR}/${PLATFORM}_${CONFIG}"
SOURCE_FILE="${OUTPUT_DIR}/libOCUser.so"

if [ ! -f "${SOURCE_FILE}" ]; then
    echo -e "  ${RED}✗${NC} libOCUser.so not found"
    echo ""
    echo -e "${RED}ERROR: Build artifact not found${NC}"
    echo "Expected: ${SOURCE_FILE}"
    echo ""
    echo "Please run 'aknbuild ${PROJECT} ${PLATFORM} ${CONFIG}' first"
    echo ""
    exit 1
fi

FILE_SIZE=$(du -h "${SOURCE_FILE}" | cut -f1)
echo -e "  ${GREEN}✓${NC} Found libOCUser.so (${FILE_SIZE})"
echo ""

# Step 2: Deploy to controller
echo -e "${YELLOW}[2/3] Deploying to controller...${NC}"

TARGET_PATH="${CNC_NATIVE_LIB_PATH}/libOCUser.so"

echo -e "  Copying libOCUser.so → ${CNC_HOST}:${TARGET_PATH}"

if scp -q "${SOURCE_FILE}" "${CNC_HOST}:${TARGET_PATH}" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Deployed successfully"
else
    echo -e "  ${RED}✗${NC} Deploy failed"
    echo ""
    echo -e "${RED}=====================================${NC}"
    echo -e "${RED}DEPLOY FAILED${NC}"
    echo -e "${RED}=====================================${NC}"
    echo ""
    echo "Failed to copy file to controller."
    echo ""
    echo "Please check:"
    echo "  1. SSH connection to '${CNC_HOST}' is working"
    echo "  2. SSH key is configured correctly"
    echo "  3. Target directory '${CNC_NATIVE_LIB_PATH}' exists on controller"
    echo ""
    echo "Test SSH connection:"
    echo "  ssh ${CNC_HOST} \"echo Connection OK\""
    echo ""
    echo "Create target directory if needed:"
    echo "  ssh ${CNC_HOST} \"mkdir -p ${CNC_NATIVE_LIB_PATH}\""
    echo ""
    exit 1
fi

echo ""

# Step 3: Verify deployment
echo -e "${YELLOW}[3/3] Verifying deployment...${NC}"

if ssh ${CNC_HOST} "ls -lh ${TARGET_PATH}" 2>/dev/null | grep -q "libOCUser.so"; then
    REMOTE_SIZE=$(ssh ${CNC_HOST} "du -h ${TARGET_PATH} 2>/dev/null | cut -f1")
    echo -e "  ${GREEN}✓${NC} File exists on controller (${REMOTE_SIZE})"
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}DEPLOY SUCCESS${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo -e "Project:  ${BLUE}${PROJECT}${NC}"
    echo -e "Platform: ${BLUE}${PLATFORM}${NC}"
    echo -e "Config:   ${BLUE}${CONFIG}${NC}"
    echo -e "Target:   ${BLUE}${CNC_HOST}:${TARGET_PATH}${NC}"
    echo ""
    echo -e "${YELLOW}Note: You may need to restart the OpenCNC service on the controller${NC}"
    echo ""
else
    echo -e "  ${RED}✗${NC} Verification failed"
    echo ""
    echo -e "${YELLOW}=====================================${NC}"
    echo -e "${YELLOW}DEPLOY WARNING${NC}"
    echo -e "${YELLOW}=====================================${NC}"
    echo ""
    echo "File was copied but verification failed."
    echo "The file may still be deployed correctly."
    echo ""
    echo "Manual verification:"
    echo "  ssh ${CNC_HOST} \"ls -lh ${TARGET_PATH}\""
    echo ""
fi
