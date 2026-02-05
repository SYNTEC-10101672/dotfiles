#!/bin/bash
# ============================================
# Appkernel Native Build Script
# Build OCUser C++ project for embedded platforms
# Usage: aknbuild <PROJECT> <PLATFORM> <CONFIG>
#   PROJECT: Project name (e.g., OCUser)
#   PLATFORM: Linux_iMX8MP_A53 | Linux_AM625_A53
#   CONFIG: Debug | Release
# Examples:
#   aknbuild OCUser Linux_iMX8MP_A53 Release
#   aknbuild OCUser Linux_AM625_A53 Debug
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
    echo "Usage: aknbuild <PROJECT> <PLATFORM> <CONFIG>"
    echo ""
    echo "Parameters:"
    echo "  PROJECT:  OCUser"
    echo "  PLATFORM: Linux_iMX8MP_A53 | Linux_AM625_A53"
    echo "  CONFIG:   Debug | Release"
    echo ""
    echo "Examples:"
    echo "  aknbuild OCUser Linux_iMX8MP_A53 Release"
    echo "  aknbuild OCUser Linux_AM625_A53 Debug"
    echo ""
    exit 1
fi

# Get parameters
PROJECT="$1"
PLATFORM="$2"
CONFIG="$3"

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
        echo "  - Linux_iMX8MP_A53 (NXP i.MX8M Plus)"
        echo "  - Linux_AM625_A53 (TI AM625)"
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
        echo "  - Debug   (with debug symbols, -g3, -O0)"
        echo "  - Release (optimized, stripped, -O3)"
        echo ""
        exit 1
        ;;
esac

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Appkernel Native Build${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${BLUE}Project:  ${PROJECT}${NC}"
echo -e "${BLUE}Platform: ${PLATFORM}${NC}"
echo -e "${BLUE}Config:   ${CONFIG}${NC}"
echo ""

# Fallback defaults (env var override still works)
OCUSER_SOURCE_DIR="${OCUSER_SOURCE_DIR:-$HOME/project/windows_project/appkernel/OCUser/Source}"

# Check required environment variables
echo -e "${YELLOW}[1/5] Checking environment variables...${NC}"

if [ ! -d "${OCUSER_SOURCE_DIR}" ]; then
    echo -e "${RED}ERROR: OCUser source directory not found${NC}"
    echo "Path: ${OCUSER_SOURCE_DIR}"
    exit 1
fi

echo -e "  ${GREEN}✓${NC} OCUSER_SOURCE_DIR: ${OCUSER_SOURCE_DIR}"

# Platform-specific SDK configuration
echo ""
echo -e "${YELLOW}[2/5] Loading SDK environment...${NC}"

case "${PLATFORM}" in
    Linux_iMX8MP_A53)
        if [ -z "${IMX8_SDK_PATH}" ]; then
            echo -e "${RED}ERROR: IMX8_SDK_PATH not set${NC}"
            echo ""
            echo "Please add this to your ~/.env:"
            echo "  export IMX8_SDK_PATH=\"/home/public_source/mgc12/embedded/toolchains/aarch64-oe-linux.12.0\""
            echo ""
            exit 1
        fi

        SDK_SETUP="${IMX8_SDK_PATH}/environment-setup-aarch64-oe-linux"

        if [ ! -f "${SDK_SETUP}" ]; then
            echo -e "${RED}ERROR: IMX8 SDK setup script not found${NC}"
            echo "Path: ${SDK_SETUP}"
            exit 1
        fi

        echo -e "  ${GREEN}✓${NC} Loading IMX8 SDK..."
        source "${SDK_SETUP}"

        # Set Makefile required environment variable
        export AARCH64_OE_LINUX_SDK_SYSROOT="${SDKTARGETSYSROOT}"

        echo -e "  ${GREEN}✓${NC} SDK loaded: MGC12 aarch64-oe-linux"
        echo -e "  ${GREEN}✓${NC} Compiler: $(aarch64-oe-linux-g++ --version | head -n1)"
        ;;

    Linux_AM625_A53)
        if [ -z "${AM625_SDK_PATH}" ]; then
            echo -e "${RED}ERROR: AM625_SDK_PATH not set${NC}"
            echo ""
            echo "Please add this to your ~/.env:"
            echo "  export AM625_SDK_PATH=\"/opt/arago-2023.04-toolchain-2023.04\""
            echo ""
            exit 1
        fi

        SDK_SETUP="${AM625_SDK_PATH}/environment-setup-aarch64-oe-linux"

        if [ ! -f "${SDK_SETUP}" ]; then
            echo -e "${RED}ERROR: AM625 SDK setup script not found${NC}"
            echo "Path: ${SDK_SETUP}"
            exit 1
        fi

        echo -e "  ${GREEN}✓${NC} Loading AM625 SDK..."
        source "${SDK_SETUP}"

        # Set Makefile required environment variables
        export ARAGO_202304_AARCH64_OE_LINUX_SDK_SYSROOT="${SDKTARGETSYSROOT}"
        export ARAGO_202304_AARCH64_OE_LINUX_SDK_BINROOT="${OECORE_NATIVE_SYSROOT}/usr/bin/aarch64-oe-linux"

        echo -e "  ${GREEN}✓${NC} SDK loaded: Arago 2023.04 aarch64-oe-linux"
        echo -e "  ${GREEN}✓${NC} Compiler: $(aarch64-oe-linux-g++ --version | head -n1)"
        ;;
esac

# Verify required environment variables are set
echo ""
echo -e "${YELLOW}[3/5] Verifying SDK configuration...${NC}"

case "${PLATFORM}" in
    Linux_iMX8MP_A53)
        if [ -z "${AARCH64_OE_LINUX_SDK_SYSROOT}" ]; then
            echo -e "${RED}ERROR: AARCH64_OE_LINUX_SDK_SYSROOT not set${NC}"
            exit 1
        fi
        echo -e "  ${GREEN}✓${NC} AARCH64_OE_LINUX_SDK_SYSROOT=${AARCH64_OE_LINUX_SDK_SYSROOT}"
        ;;
    Linux_AM625_A53)
        if [ -z "${ARAGO_202304_AARCH64_OE_LINUX_SDK_SYSROOT}" ]; then
            echo -e "${RED}ERROR: ARAGO_202304_AARCH64_OE_LINUX_SDK_SYSROOT not set${NC}"
            exit 1
        fi
        if [ -z "${ARAGO_202304_AARCH64_OE_LINUX_SDK_BINROOT}" ]; then
            echo -e "${RED}ERROR: ARAGO_202304_AARCH64_OE_LINUX_SDK_BINROOT not set${NC}"
            exit 1
        fi
        echo -e "  ${GREEN}✓${NC} ARAGO_202304_AARCH64_OE_LINUX_SDK_SYSROOT=${ARAGO_202304_AARCH64_OE_LINUX_SDK_SYSROOT}"
        echo -e "  ${GREEN}✓${NC} ARAGO_202304_AARCH64_OE_LINUX_SDK_BINROOT=${ARAGO_202304_AARCH64_OE_LINUX_SDK_BINROOT}"
        ;;
esac

# Execute build
echo ""
echo -e "${YELLOW}[4/5] Building ${PROJECT} solution...${NC}"
echo ""

cd "${OCUSER_SOURCE_DIR}"

# Run make
if make Build ${PLATFORM} ${CONFIG} _OCUser_Sln; then
    BUILD_SUCCESS=true
else
    BUILD_SUCCESS=false
fi

echo ""

# Verify build artifacts
echo -e "${YELLOW}[5/5] Verifying build artifacts...${NC}"

OUTPUT_DIR="${OCUSER_SOURCE_DIR}/${PLATFORM}_${CONFIG}"
OUTPUT_FILE="${OUTPUT_DIR}/libOCUser.so"

if [ -f "${OUTPUT_FILE}" ]; then
    FILE_SIZE=$(du -h "${OUTPUT_FILE}" | cut -f1)
    echo -e "  ${GREEN}✓${NC} libOCUser.so generated (${FILE_SIZE})"
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}BUILD SUCCESS${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo -e "Project:  ${BLUE}${PROJECT}${NC}"
    echo -e "Platform: ${BLUE}${PLATFORM}${NC}"
    echo -e "Config:   ${BLUE}${CONFIG}${NC}"
    echo -e "Output:   ${BLUE}${OUTPUT_FILE}${NC}"
    echo ""
    exit 0
else
    echo -e "  ${RED}✗${NC} libOCUser.so not found"
    echo ""
    echo -e "${RED}=====================================${NC}"
    echo -e "${RED}BUILD FAILED${NC}"
    echo -e "${RED}=====================================${NC}"
    echo ""
    echo "Expected output: ${OUTPUT_FILE}"
    echo ""
    echo "Please check the build log above for errors."
    echo ""
    exit 1
fi
