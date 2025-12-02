#!/bin/bash

# Script to create the default D&D campaign file structure
# Based on the structure described in @.dungeon/Dungeon Master Prompt.md

set -e

# Default values
DRY_RUN=false
VERBOSE=false
CAMPAIGN_NAME=""
BASE_DIR="$(pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] CAMPAIGN_NAME"
    echo ""
    echo "Create a D&D campaign file structure."
    echo ""
    echo "Arguments:"
    echo "  CAMPAIGN_NAME    Name of the campaign to create"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -d, --dry-run   Show what would be created without creating files"
    echo "  -v, --verbose   Show detailed output"
    echo "  -q, --quiet     Suppress output (except errors)"
    echo ""
    echo "Examples:"
    echo "  $0 \"Dragon's Legacy\""
    echo "  $0 --dry-run \"Curse of Strahd\""
    echo "  $0 -v \"Waterdeep Heist\""
    exit 1
}

# Logging functions
log_info() {
    if [ "$VERBOSE" = true ] || [ "$QUIET" != true ]; then
        echo -e "${GREEN}✓${NC} $1"
    fi
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1" >&2
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            if [ -z "$CAMPAIGN_NAME" ]; then
                CAMPAIGN_NAME="$1"
            else
                log_error "Multiple campaign names provided: '$CAMPAIGN_NAME' and '$1'"
                usage
            fi
            shift
            ;;
    esac
done

# Validate campaign name
if [ -z "$CAMPAIGN_NAME" ]; then
    log_error "Campaign name is required"
    usage
fi

# Sanitize campaign name (remove spaces and special characters, keep letters, numbers, hyphens, underscores)
SANITIZED_NAME=$(echo "$CAMPAIGN_NAME" | sed 's/[^a-zA-Z0-9_-]//g')
if [ -z "$SANITIZED_NAME" ]; then
    log_error "Campaign name contains no valid characters"
    exit 1
fi

# Use absolute path for reliability
CAMPAIGN_DIR="$BASE_DIR/$SANITIZED_NAME"

# Validate write permissions and disk space
check_permissions() {
    # Check write permissions to base directory
    if [ ! -w "$BASE_DIR" ]; then
        log_error "No write permission to base directory: $BASE_DIR"
        exit 1
    fi

    # Check if we can create a test file
    local test_file="$BASE_DIR/.campaign_script_test_$$"
    if ! touch "$test_file" 2>/dev/null; then
        log_error "Cannot create files in base directory: $BASE_DIR"
        exit 1
    fi
    rm -f "$test_file"

    # Check available disk space (require at least 10MB)
    local available_space
    if command -v df >/dev/null 2>&1; then
        available_space=$(df -k "$BASE_DIR" | awk 'NR==2 {print $4}')
        local min_space_kb=10240  # 10MB in KB
        
        if [ "$available_space" -lt "$min_space_kb" ]; then
            log_error "Insufficient disk space. Required: 10MB, Available: $((available_space/1024))MB"
            exit 1
        fi
        
        if [ "$VERBOSE" = true ]; then
            log_info "Disk space check passed: $((available_space/1024))MB available"
        fi
    fi
}

check_permissions

# Display what will be created
if [ "$DRY_RUN" = true ] || [ "$VERBOSE" = true ]; then
    echo "Creating D&D campaign file structure..."
    echo "Campaign name: $CAMPAIGN_NAME"
    echo "Sanitized name: $SANITIZED_NAME"
    echo "Base directory: $BASE_DIR"
    echo "Campaign directory: $CAMPAIGN_DIR"
    if [ "$DRY_RUN" = true ]; then
        echo ""
        echo "DRY RUN: No files will be created"
    fi
    echo ""
fi

# Create the main campaign directory if it doesn't exist
if [ ! -d "$CAMPAIGN_DIR" ]; then
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$CAMPAIGN_DIR"
        log_info "Created Campaign directory: $CAMPAIGN_DIR"
    else
        log_info "Would create Campaign directory: $CAMPAIGN_DIR"
    fi
else
    log_info "Campaign directory already exists: $CAMPAIGN_DIR"
fi

# Create subdirectories
directories=("Locations" "NPCs" "Organizations" "Resources" "Sessions" "Players")

for dir in "${directories[@]}"; do
    if [ ! -d "$CAMPAIGN_DIR/$dir" ]; then
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$CAMPAIGN_DIR/$dir"
            log_info "Created $dir/ directory"
        else
            log_info "Would create $dir/ directory"
        fi
    else
        log_info "$dir/ directory already exists"
    fi
done

# Create root-level files with templates if they don't exist
files=("Hooks.md" "Campaign.md")

# Template content
create_hooks_template() {
    cat > "$1" << 'EOF'
# Campaign Hooks

## Major Plot Hooks
- 

## Minor Plot Hooks
- 

## One-Shot Adventures
- 

## Character-Specific Hooks
- 

## Location-Based Hooks
- 
EOF
}

create_campaign_template() {
    cat > "$1" << EOF
# $CAMPAIGN_NAME

## Campaign Overview
**Setting:** 
**Level Range:** 
**Theme:** 

## Synopsis


## Key NPCs


## Important Locations


## Major Factions


## Campaign Timeline


## Session Log
| Session | Date | Summary |
|---------|------|---------|
| 1 | | |
EOF
}

for file in "${files[@]}"; do
    if [ ! -f "$CAMPAIGN_DIR/$file" ]; then
        if [ "$DRY_RUN" = false ]; then
            case "$file" in
                "Hooks.md")
                    create_hooks_template "$CAMPAIGN_DIR/$file"
                    ;;
                "Campaign.md")
                    create_campaign_template "$CAMPAIGN_DIR/$file"
                    ;;
            esac
            log_info "Created $file with template content"
        else
            log_info "Would create $file with template content"
        fi
    else
        log_info "$file already exists"
    fi
done

# Display completion message
if [ "$DRY_RUN" = false ]; then
    log_info "File structure creation complete!"
else
    log_info "Dry run complete - no files were created"
fi

if [ "$QUIET" != true ]; then
    echo ""
    echo "Created structure:"
    echo "$SANITIZED_NAME/"
    echo "├── Locations/      # Location entries (towns, buildings, landmarks)"
    echo "├── NPCs/           # Non-player character files"
    echo "├── Organizations/  # Faction and group information"
    echo "├── Resources/      # Game resources, creatures, items"
    echo "├── Sessions/       # Session notes and recaps"
    echo "├─Hooks.md          # Plot hooks and story ideas"
    echo "├─Campaign.md       # Campaign overview"
    echo "└── Players/        # PC information"
    echo ""
fi