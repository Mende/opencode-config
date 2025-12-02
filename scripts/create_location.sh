#!/bin/bash

# create_location.sh
# Script to create a location entry if it doesn't exist
#
# Usage: ./create_location.sh [OPTIONS] <location_name>
# - Creates a new location entry using the Location template
# - Sanitizes name for safe filename creation
# - Updates title and name fields in the created file
#
# Args:
#   location_name: Name of the location to create
#
# Requirements:
# - Template file: template/Location.md
# - Locations directory will be created if it doesn't exist
#
# Output:
# - Creates [sanitized_location_name].md in Locations/ directory
# - Prints status messages to stdout

set -e

# Default values
DRY_RUN=false
VERBOSE=false
QUIET=false
OVERWRITE=false
LOCATION_NAME=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory and base paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LOCATIONS_DIR="$BASE_DIR/Locations"
TEMPLATE_FILE="$SCRIPT_DIR/template/Location.md"

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] LOCATION_NAME"
    echo ""
    echo "Create a new location entry from template."
    echo ""
    echo "Arguments:"
    echo "  LOCATION_NAME     Name of the location to create"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -d, --dry-run   Show what would be created without creating files"
    echo "  -v, --verbose   Show detailed output"
    echo "  -q, --quiet     Suppress output (except errors)"
    echo "  -o, --overwrite Overwrite existing location file"
    echo ""
    echo "Examples:"
    echo "  $0 \"Dragon's Lair\""
    echo "  $0 --dry-run \"Forgotten Temple\""
    echo "  $0 -v \"Waterdeep Harbor\""
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
            if [ -z "$LOCATION_NAME" ]; then
                LOCATION_NAME="$1"
            else
                log_error "Multiple location names provided: '$LOCATION_NAME' and '$1'"
                usage
            fi
            shift
            ;;
    esac
done

# Validate location name
if [ -z "$LOCATION_NAME" ]; then
    log_error "Location name is required"
    usage
fi

# Sanitize location name for filename (spaces to underscores, remove special chars)
SANITIZED_NAME=$(echo "$LOCATION_NAME" | sed 's/[^a-zA-Z0-9 _-]//g' | sed 's/ /_/g')
if [ -z "$SANITIZED_NAME" ]; then
    log_error "Location name contains no valid characters"
    exit 1
fi

LOCATION_FILE="$LOCATIONS_DIR/${SANITIZED_NAME}.md"

# Display what will be created
if [ "$DRY_RUN" = true ] || [ "$VERBOSE" = true ]; then
    echo "Creating location entry..."
    echo "Location name: $LOCATION_NAME"
    echo "Sanitized name: $SANITIZED_NAME"
    echo "Locations directory: $LOCATIONS_DIR"
    echo "Template file: $TEMPLATE_FILE"
    echo "Output file: $LOCATION_FILE"
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
if [ ! -w "$(dirname "$LOCATIONS_DIR")" ] && [ ! -d "$LOCATIONS_DIR" ]; then
    log_error "No write permission to create Locations directory"
    exit 1
fi

if [ -d "$LOCATIONS_DIR" ] && [ ! -w "$LOCATIONS_DIR" ]; then
    log_error "No write permission to Locations directory: $LOCATIONS_DIR"
    exit 1
fi

# Ensure locations directory exists
if [ ! -d "$LOCATIONS_DIR" ]; then
    if [ "$DRY_RUN" = false ]; then
        if ! mkdir -p "$LOCATIONS_DIR"; then
            log_error "Could not create Locations directory '$LOCATIONS_DIR'"
            exit 1
        fi
        log_info "Created Locations directory: $LOCATIONS_DIR"
    else
        log_info "Would create Locations directory: $LOCATIONS_DIR"
    fi
fi

# Check for existing location
if [ -f "$LOCATION_FILE" ]; then
    if [ "$OVERWRITE" = false ]; then
        log_warn "Location '$LOCATION_NAME' already exists at '$LOCATION_FILE'"
        log_warn "Use --overwrite to replace it"
        exit 1
    else
        log_warn "Overwriting existing location: $LOCATION_FILE"
    fi
fi

# Create new location entry from template
if [ "$DRY_RUN" = false ]; then
    if ! cp "$TEMPLATE_FILE" "$LOCATION_FILE"; then
        log_error "Failed to copy template to '$LOCATION_FILE'"
        exit 1
    fi
    log_info "Created location file: $LOCATION_FILE"

    # Update template placeholders with location name
    # Use cross-platform sed syntax
    if command -v gsed >/dev/null 2>&1; then
        SED_CMD="gsed"
    else
        SED_CMD="sed"
    fi

    if ! $SED_CMD -i.bak "s|# Location Template|# $LOCATION_NAME|" "$LOCATION_FILE"; then
        log_error "Failed to update title in '$LOCATION_FILE'"
        exit 1
    fi
    
    if ! $SED_CMD -i.bak "s|- \*\*Name:\*\* |- **Name:** $LOCATION_NAME|" "$LOCATION_FILE"; then
        log_error "Failed to update name in '$LOCATION_FILE'"
        exit 1
    fi

    # Remove backup files created by sed
    rm -f "$LOCATION_FILE.bak"

    log_info "Updated location name in template"
else
    log_info "Would create location file: $LOCATION_FILE"
    log_info "Would update template with location name: $LOCATION_NAME"
fi

# Display completion message
if [ "$DRY_RUN" = false ]; then
    log_info "Location creation complete!"
else
    log_info "Dry run complete - no files were created"
fi