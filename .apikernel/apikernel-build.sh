#!/bin/bash
# ============================================
# Apikernel Build Script
# Cross-compile apikernel for embedded platforms
# Usage: apikbuild <PLATFORM> <CONFIG>
#   PLATFORM: Linux_iMX8MP_A53 | Linux_AM625_A53
#   CONFIG: Debug | Release
# Examples:
#   apikbuild Linux_iMX8MP_A53 Debug
#   apikbuild Linux_AM625_A53 Release
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
    echo "Usage: apikbuild <PLATFORM> <CONFIG>"
    echo ""
    echo "Parameters:"
    echo "  PLATFORM: Linux_iMX8MP_A53 | Linux_AM625_A53"
    echo "  CONFIG:   Debug | Release"
    echo ""
    echo "Examples:"
    echo "  apikbuild Linux_iMX8MP_A53 Debug"
    echo "  apikbuild Linux_AM625_A53 Release"
    echo ""
    exit 1
fi

# Get parameters
PLATFORM="$1"
CONFIG="$2"

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
echo -e "${BLUE}Apikernel Build${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${BLUE}Platform: ${PLATFORM}${NC}"
echo -e "${BLUE}Config:   ${CONFIG}${NC}"
echo ""

# Check required environment variables
echo -e "${YELLOW}[1/5] Checking environment variables...${NC}"

if [ -z "${APIKERNEL_BUILD_DIR}" ]; then
    echo -e "${RED}ERROR: APIKERNEL_BUILD_DIR not set${NC}"
    echo ""
    echo "Please add this to your ~/.env:"
    echo "  export APIKERNEL_BUILD_DIR=\"\${HOME}/project/windows_project/apikernel/Build\""
    echo ""
    echo "Then reload: source ~/.env"
    exit 1
fi

if [ ! -d "${APIKERNEL_BUILD_DIR}" ]; then
    echo -e "${RED}ERROR: Build directory not found${NC}"
    echo "Path: ${APIKERNEL_BUILD_DIR}"
    exit 1
fi

echo -e "  ${GREEN}✓${NC} APIKERNEL_BUILD_DIR: ${APIKERNEL_BUILD_DIR}"

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

# Verify SDK configuration
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
echo -e "${YELLOW}[4/5] Building apikernel...${NC}"
echo ""

cd "${APIKERNEL_BUILD_DIR}"

# Run make with key=value syntax (Build/Makefile convention)
if make "Action=Build" "TargetPlatform=${PLATFORM}" "ConfigMode=${CONFIG}"; then
    BUILD_SUCCESS=true
else
    BUILD_SUCCESS=false
fi

echo ""

# Verify build artifacts
echo -e "${YELLOW}[5/5] Verifying build artifacts...${NC}"

OCSDK_BASE="${APIKERNEL_BUILD_DIR}/../OCSDK"
LIB_FILE="${OCSDK_BASE}/lib/${PLATFORM}/${CONFIG}/libOCAPI.so"
EXE_FILE="${OCSDK_BASE}/bin/${PLATFORM}/${CONFIG}/OCHost.out"
BUILD_LOG="${APIKERNEL_BUILD_DIR}/BuildLog_Linux/OCAPI_${PLATFORM}_${CONFIG}.txt"

if [ "$BUILD_SUCCESS" = true ] && [ -f "${LIB_FILE}" ] && [ -f "${EXE_FILE}" ]; then
    LIB_SIZE=$(du -h "${LIB_FILE}" | cut -f1)
    EXE_SIZE=$(du -h "${EXE_FILE}" | cut -f1)
    echo -e "  ${GREEN}✓${NC} libOCAPI.so  (${LIB_SIZE})"
    echo -e "  ${GREEN}✓${NC} OCHost.out   (${EXE_SIZE})"
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}BUILD SUCCESS${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo -e "Platform: ${BLUE}${PLATFORM}${NC}"
    echo -e "Config:   ${BLUE}${CONFIG}${NC}"
    echo -e "Library:  ${BLUE}${LIB_FILE}${NC}"
    echo -e "Executable: ${BLUE}${EXE_FILE}${NC}"
    [ -f "${BUILD_LOG}" ] && echo -e "Build log: ${BLUE}${BUILD_LOG}${NC}"
    echo ""
    exit 0
else
    echo -e "  ${RED}✗${NC} Build artifacts not found or incomplete"
    [ ! -f "${LIB_FILE}" ] && echo -e "  ${RED}✗${NC} Missing: ${LIB_FILE}"
    [ ! -f "${EXE_FILE}" ] && echo -e "  ${RED}✗${NC} Missing: ${EXE_FILE}"
    echo ""
    echo -e "${RED}=====================================${NC}"
    echo -e "${RED}BUILD FAILED${NC}"
    echo -e "${RED}=====================================${NC}"
    echo ""
    [ -f "${BUILD_LOG}" ] && echo "Build log: ${BUILD_LOG}"
    echo "Please check the build log above for errors."
    echo ""
    exit 1
fi
