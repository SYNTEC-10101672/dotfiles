#!/bin/bash
# ============================================
# Apikernel Deploy Script
# Deploy libOCAPI.so to CNC controller
# Usage: apikdeploy <PLATFORM> <CONFIG>
#   PLATFORM: Linux_iMX8MP_A53 | Linux_AM625_A53
#   CONFIG: Debug | Release
# Examples:
#   apikdeploy Linux_iMX8MP_A53 Debug
#   apikdeploy Linux_AM625_A53 Release
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
    echo "Usage: apikdeploy <PLATFORM> <CONFIG>"
    echo ""
    echo "Parameters:"
    echo "  PLATFORM: Linux_iMX8MP_A53 | Linux_AM625_A53"
    echo "  CONFIG:   Debug | Release"
    echo ""
    echo "Examples:"
    echo "  apikdeploy Linux_iMX8MP_A53 Debug"
    echo "  apikdeploy Linux_AM625_A53 Release"
    echo ""
    exit 1
fi

# Get parameters
PLATFORM="$1"
CONFIG="$2"

# CNC controller configuration (from ~/.ssh/config)
CNC_HOST="${CNC_HOST:-cnc}"

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
echo -e "${BLUE}Apikernel Deploy${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${BLUE}Platform: ${PLATFORM}${NC}"
echo -e "${BLUE}Config:   ${CONFIG}${NC}"
echo -e "${BLUE}Target:   ${CNC_HOST}${NC}"
echo ""

# Check required environment variables
if [ -z "${APIKERNEL_BUILD_DIR}" ]; then
    echo -e "${RED}ERROR: APIKERNEL_BUILD_DIR not set${NC}"
    echo ""
    echo "Please add this to your ~/.env:"
    echo "  export APIKERNEL_BUILD_DIR=\"\${HOME}/project/windows_project/apikernel/Build\""
    echo ""
    echo "Then reload: source ~/.env"
    exit 1
fi

if [ -z "${CNC_NATIVE_LIB_PATH}" ]; then
    echo -e "${RED}ERROR: CNC_NATIVE_LIB_PATH not set${NC}"
    echo ""
    echo "Please add this to your ~/.env:"
    echo "  export CNC_NATIVE_LIB_PATH=\"/DiskC/OpenCNC/Bin\""
    echo ""
    exit 1
fi

# Step 1: Locate build artifact
echo -e "${YELLOW}[1/3] Locating build artifact...${NC}"

SOURCE_FILE="${APIKERNEL_BUILD_DIR}/../OCSDK/lib/${PLATFORM}/${CONFIG}/libOCAPI.so"

if [ ! -f "${SOURCE_FILE}" ]; then
    echo -e "  ${RED}✗${NC} libOCAPI.so not found"
    echo ""
    echo -e "${RED}ERROR: Build artifact not found${NC}"
    echo "Expected: ${SOURCE_FILE}"
    echo ""
    echo "Please run 'apikbuild ${PLATFORM} ${CONFIG}' first"
    echo ""
    exit 1
fi

FILE_SIZE=$(du -h "${SOURCE_FILE}" | cut -f1)
echo -e "  ${GREEN}✓${NC} Found libOCAPI.so (${FILE_SIZE})"
echo ""

# Step 2: Deploy to controller
echo -e "${YELLOW}[2/3] Deploying to controller...${NC}"

TARGET_PATH="${CNC_NATIVE_LIB_PATH}/libOCAPI.so"

echo -e "  Copying libOCAPI.so → ${CNC_HOST}:${TARGET_PATH}"

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

if ssh ${CNC_HOST} "ls -lh ${TARGET_PATH}" 2>/dev/null | grep -q "libOCAPI.so"; then
    REMOTE_SIZE=$(ssh ${CNC_HOST} "du -h ${TARGET_PATH} 2>/dev/null | cut -f1")
    echo -e "  ${GREEN}✓${NC} File exists on controller (${REMOTE_SIZE})"
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}DEPLOY SUCCESS${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
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
