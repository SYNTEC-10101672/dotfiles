#!/bin/bash
# ============================================
# Appkernel Deploy Script
# Deploy compiled artifacts to CNC controller
# Usage: akdeploy <PROJECT> <CONFIG>
#   PROJECT: Project name (e.g., MMICommon32)
#   CONFIG: Configuration (e.g., ReleaseEL, DebugEL)
# Examples:
#   akdeploy MMICommon32 ReleaseEL
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
    echo "Usage: akdeploy <PROJECT> <CONFIG>"
    echo ""
    echo "Examples:"
    echo "  akdeploy MMICommon32 ReleaseEL"
    echo ""
    exit 1
fi

# Get parameters
PROJECT="$1"
CONFIG="$2"

# CNC controller configuration (from ~/.ssh/config)
CNC_HOST="cnc"
CNC_TARGET_DIR="/DiskC/Shared/dotnet/"

# Base directory for build artifacts
BUILD_BASE_DIR="${HOME}/project/windows_project/appkernel"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Appkernel Deploy${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${BLUE}Project: ${PROJECT}${NC}"
echo -e "${BLUE}Config:  ${CONFIG}${NC}"
echo -e "${BLUE}Target:  ${CNC_HOST}:${CNC_TARGET_DIR}${NC}"
echo ""

# Define deployment rules for each project
# Format: "source_file|target_file|fallback_file1,fallback_file2,..."
# If source_file not found, try fallback files in order
declare -a DEPLOY_RULES=()
SOURCE_DIR=""

case "${PROJECT}" in
    MMICommon32)
        SOURCE_DIR="${BUILD_BASE_DIR}/MMICommon/Source/bin32/${CONFIG}"
        DEPLOY_RULES=(
            "Syntec.OpenCNC.dll|Syntec.OpenCNC.dll|"
            "MMICommon.dll|MMICommon.dll|"
        )
        ;;
    *)
        echo -e "${RED}ERROR: Unknown project '${PROJECT}'${NC}"
        echo ""
        echo "Supported projects:"
        echo "  - MMICommon32"
        echo ""
        exit 1
        ;;
esac

# Step 1: Check if all build artifacts exist and resolve file names
echo -e "${YELLOW}[1/3] Checking build artifacts...${NC}"

declare -a RESOLVED_FILES=()
MISSING_FILES=0

for rule in "${DEPLOY_RULES[@]}"; do
    # Parse rule: source|target|fallbacks
    IFS='|' read -r source_file target_file fallbacks <<< "$rule"

    FOUND_FILE=""
    DISPLAY_NAME="${target_file}"

    # Try source file first
    if [ -f "${SOURCE_DIR}/${source_file}" ]; then
        FOUND_FILE="${source_file}"
        echo -e "  ${GREEN}✓${NC} ${DISPLAY_NAME} (using ${source_file})"
    else
        # Try fallback files
        IFS=',' read -ra FALLBACK_ARRAY <<< "$fallbacks"
        for fallback in "${FALLBACK_ARRAY[@]}"; do
            if [ -n "$fallback" ] && [ -f "${SOURCE_DIR}/${fallback}" ]; then
                FOUND_FILE="${fallback}"
                echo -e "  ${GREEN}✓${NC} ${DISPLAY_NAME} (using ${fallback})"
                break
            fi
        done
    fi

    if [ -n "$FOUND_FILE" ]; then
        # Store as "actual_source_file|target_file"
        RESOLVED_FILES+=("${FOUND_FILE}|${target_file}")
    else
        echo -e "  ${RED}✗${NC} ${DISPLAY_NAME} ${RED}(not found)${NC}"
        if [ -n "$fallbacks" ]; then
            echo -e "      Tried: ${source_file}, ${fallbacks}"
        else
            echo -e "      Tried: ${source_file}"
        fi
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ ${MISSING_FILES} -gt 0 ]; then
    echo ""
    echo -e "${RED}ERROR: ${MISSING_FILES} file(s) missing${NC}"
    echo ""
    echo -e "Source directory: ${SOURCE_DIR}"
    echo ""
    echo "Please run 'akbuild ${PROJECT} ${CONFIG}' first"
    exit 1
fi

echo ""

# Step 2: Deploy files to controller
echo -e "${YELLOW}[2/3] Deploying to controller...${NC}"

DEPLOY_FAILED=0
for resolved in "${RESOLVED_FILES[@]}"; do
    IFS='|' read -r source_file target_file <<< "$resolved"

    SOURCE_PATH="${SOURCE_DIR}/${source_file}"
    TARGET_PATH="${CNC_TARGET_DIR}${target_file}"

    if [ "$source_file" != "$target_file" ]; then
        echo -e "  ${source_file} → ${CNC_HOST}:${TARGET_PATH} (as ${target_file})"
    else
        echo -e "  ${source_file} → ${CNC_HOST}:${CNC_TARGET_DIR}"
    fi

    if scp -q "${SOURCE_PATH}" "${CNC_HOST}:${TARGET_PATH}" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Deployed successfully"
    else
        echo -e "  ${RED}✗${NC} Deploy failed"
        DEPLOY_FAILED=$((DEPLOY_FAILED + 1))
    fi
done

echo ""

# Step 3: Verify deployment
if [ ${DEPLOY_FAILED} -eq 0 ]; then
    echo -e "${YELLOW}[3/3] Verifying deployment...${NC}"
    echo -e "  ${GREEN}✓${NC} All files deployed successfully"
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}DEPLOY SUCCESS${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo -e "Project: ${BLUE}${PROJECT}${NC}"
    echo -e "Config:  ${BLUE}${CONFIG}${NC}"
    echo -e "Files:   ${BLUE}${#RESOLVED_FILES[@]} deployed${NC}"
    echo ""
else
    echo -e "${RED}=====================================${NC}"
    echo -e "${RED}DEPLOY FAILED${NC}"
    echo -e "${RED}=====================================${NC}"
    echo ""
    echo -e "${DEPLOY_FAILED} file(s) failed to deploy"
    echo ""
    echo "Please check:"
    echo "  1. SSH connection to '${CNC_HOST}' is working"
    echo "  2. SSH key is configured correctly"
    echo "  3. Target directory '${CNC_TARGET_DIR}' exists on controller"
    echo ""
    exit 1
fi
