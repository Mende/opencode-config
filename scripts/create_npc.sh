#!/bin/bash

# create_npc.sh
# Script to create an NPC entry if it doesn't exist
#
# Usage: ./create_npc.sh [OPTIONS] <npc_name>
# - Creates a new NPC entry using the NPC template
# - Sanitizes name for safe filename creation
# - Updates title and name fields in the created file
#
# Args:
#   npc_name: Name of the NPC to create
#
# Requirements:
# - Template file: template/NPC.md
# - NPCs directory will be created if it doesn't exist
#
# Output:
# - Creates [sanitized_npc_name].md in NPCs/ directory
# - Prints status messages to stdout

set -e

# Default values
DRY_RUN=false
VERBOSE=false
QUIET=false
OVERWRITE=false
NPC_NAME=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory and base paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
NPCS_DIR="$BASE_DIR/NPCs"
TEMPLATE_FILE="$SCRIPT_DIR/template/NPC.md"

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] NPC_NAME"
    echo ""
    echo "Create a new NPC entry from template."
    echo ""
    echo "Arguments:"
    echo "  NPC_NAME        Name of the NPC to create"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -d, --dry-run   Show what would be created without creating files"
    echo "  -v, --verbose   Show detailed output"
    echo "  -q, --quiet     Suppress output (except errors)"
    echo "  -o, --overwrite Overwrite existing NPC file"
    echo ""
    echo "Examples:"
    echo "  $0 \"Gandalf the Grey\""
    echo "  $0 --dry-run \"Elminster Aumar\""
    echo "  $0 -v \"Strahd von Zarovich\""
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
        -o|--overwrite)
            OVERWRITE=true
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            if [ -z "$NPC_NAME" ]; then
                NPC_NAME="$1"
            else
                log_error "Multiple NPC names provided: '$NPC_NAME' and '$1'"
                usage
            fi
            shift
            ;;
    esac
done

# Validate NPC name
if [ -z "$NPC_NAME" ]; then
    log_error "NPC name is required"
    usage
fi

# Sanitize NPC name for filename (spaces to underscores, remove special chars)
SANITIZED_NAME=$(echo "$NPC_NAME" | sed 's/[^a-zA-Z0-9 _-]//g' | sed 's/ /_/g')
if [ -z "$SANITIZED_NAME" ]; then
    log_error "NPC name contains no valid characters"
    exit 1
fi

NPC_FILE="$NPCS_DIR/${SANITIZED_NAME}.md"

# Display what will be created
if [ "$DRY_RUN" = true ] || [ "$VERBOSE" = true ]; then
    echo "Creating NPC entry..."
    echo "NPC name: $NPC_NAME"
    echo "Sanitized name: $SANITIZED_NAME"
    echo "NPCs directory: $NPCS_DIR"
    echo "Template file: $TEMPLATE_FILE"
    echo "Output file: $NPC_FILE"
    if [ "$DRY_RUN" = true ]; then
        echo ""
        echo "DRY RUN: No files will be created"
    fi
    echo ""
fi

# Validate prerequisites
if [ ! -f "$TEMPLATE_FILE" ]; then
    log_error "Template file '$TEMPLATE_FILE' not found"
    exit 1
fi

# Check write permissions
if [ ! -w "$(dirname "$NPCS_DIR")" ] && [ ! -d "$NPCS_DIR" ]; then
    log_error "No write permission to create NPCs directory"
    exit 1
fi

if [ -d "$NPCS_DIR" ] && [ ! -w "$NPCS_DIR" ]; then
    log_error "No write permission to NPCs directory: $NPCS_DIR"
    exit 1
fi

# Ensure NPCs directory exists
if [ ! -d "$NPCS_DIR" ]; then
    if [ "$DRY_RUN" = false ]; then
        if ! mkdir -p "$NPCS_DIR"; then
            log_error "Could not create NPCs directory '$NPCS_DIR'"
            exit 1
        fi
        log_info "Created NPCs directory: $NPCS_DIR"
    else
        log_info "Would create NPCs directory: $NPCS_DIR"
    fi
fi

# Check for existing NPC
if [ -f "$NPC_FILE" ]; then
    if [ "$OVERWRITE" = false ]; then
        log_warn "NPC '$NPC_NAME' already exists at '$NPC_FILE'"
        log_warn "Use --overwrite to replace it"
        exit 1
    else
        log_warn "Overwriting existing NPC: $NPC_FILE"
    fi
fi

# Create new NPC entry from template
if [ "$DRY_RUN" = false ]; then
    if ! cp "$TEMPLATE_FILE" "$NPC_FILE"; then
        log_error "Failed to copy template to '$NPC_FILE'"
        exit 1
    fi
    log_info "Created NPC file: $NPC_FILE"

    # Update template placeholders with NPC name
    # Use cross-platform sed syntax
    if command -v gsed >/dev/null 2>&1; then
        SED_CMD="gsed"
    else
        SED_CMD="sed"
    fi

    if ! $SED_CMD -i.bak "s|# NPC Template|# $NPC_NAME|" "$NPC_FILE"; then
        log_error "Failed to update title in '$NPC_FILE'"
        exit 1
    fi
    
    if ! $SED_CMD -i.bak "s|- \*\*Name:\*\* |- **Name:** $NPC_NAME|" "$NPC_FILE"; then
        log_error "Failed to update name in '$NPC_FILE'"
        exit 1
    fi

    # Remove backup files created by sed
    rm -f "$NPC_FILE.bak"

    log_info "Updated NPC name in template"
else
    log_info "Would create NPC file: $NPC_FILE"
    log_info "Would update template with NPC name: $NPC_NAME"
fi

# Display completion message
if [ "$DRY_RUN" = false ]; then
    log_info "NPC creation complete!"
else
    log_info "Dry run complete - no files were created"
fi