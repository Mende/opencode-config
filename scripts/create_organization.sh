#!/bin/bash

# create_organization.sh
# Script to create an organization entry if it doesn't exist
#
# Usage: ./create_organization.sh [OPTIONS] <organization_name>
# - Creates a new organization entry using the Organization template
# - Sanitizes name for safe filename creation
# - Updates title and name fields in the created file
#
# Args:
#   organization_name: Name of the organization to create
#
# Requirements:
# - Template file: template/Organization.md
# - Organizations directory will be created if it doesn't exist
#
# Output:
# - Creates [sanitized_organization_name].md in Organizations/ directory
# - Prints status messages to stdout

set -e

# Default values
DRY_RUN=false
VERBOSE=false
QUIET=false
OVERWRITE=false
ORG_NAME=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory and base paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
ORGANIZATIONS_DIR="$BASE_DIR/Organizations"
TEMPLATE_FILE="$SCRIPT_DIR/template/Organization.md"

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] ORGANIZATION_NAME"
    echo ""
    echo "Create a new organization entry from template."
    echo ""
    echo "Arguments:"
    echo "  ORGANIZATION_NAME  Name of the organization to create"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -d, --dry-run   Show what would be created without creating files"
    echo "  -v, --verbose   Show detailed output"
    echo "  -q, --quiet     Suppress output (except errors)"
    echo "  -o, --overwrite Overwrite existing organization file"
    echo ""
    echo "Examples:"
    echo "  $0 \"Thieves Guild\""
    echo "  $0 --dry-run \"Royal Knights\""
    echo "  $0 -v \"Merchant Alliance\""
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
            if [ -z "$ORG_NAME" ]; then
                ORG_NAME="$1"
            else
                log_error "Multiple organization names provided: '$ORG_NAME' and '$1'"
                usage
            fi
            shift
            ;;
    esac
done

# Validate organization name
if [ -z "$ORG_NAME" ]; then
    log_error "Organization name is required"
    usage
fi

# Sanitize organization name for filename (spaces to underscores, remove special chars)
SANITIZED_NAME=$(echo "$ORG_NAME" | sed 's/[^a-zA-Z0-9 _-]//g' | sed 's/ /_/g')
if [ -z "$SANITIZED_NAME" ]; then
    log_error "Organization name contains no valid characters"
    exit 1
fi

ORG_FILE="$ORGANIZATIONS_DIR/${SANITIZED_NAME}.md"

# Display what will be created
if [ "$DRY_RUN" = true ] || [ "$VERBOSE" = true ]; then
    echo "Creating organization entry..."
    echo "Organization name: $ORG_NAME"
    echo "Sanitized name: $SANITIZED_NAME"
    echo "Organizations directory: $ORGANIZATIONS_DIR"
    echo "Template file: $TEMPLATE_FILE"
    echo "Output file: $ORG_FILE"
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
if [ ! -w "$(dirname "$ORGANIZATIONS_DIR")" ] && [ ! -d "$ORGANIZATIONS_DIR" ]; then
    log_error "No write permission to create Organizations directory"
    exit 1
fi

if [ -d "$ORGANIZATIONS_DIR" ] && [ ! -w "$ORGANIZATIONS_DIR" ]; then
    log_error "No write permission to Organizations directory: $ORGANIZATIONS_DIR"
    exit 1
fi

# Ensure organizations directory exists
if [ ! -d "$ORGANIZATIONS_DIR" ]; then
    if [ "$DRY_RUN" = false ]; then
        if ! mkdir -p "$ORGANIZATIONS_DIR"; then
            log_error "Could not create Organizations directory '$ORGANIZATIONS_DIR'"
            exit 1
        fi
        log_info "Created Organizations directory: $ORGANIZATIONS_DIR"
    else
        log_info "Would create Organizations directory: $ORGANIZATIONS_DIR"
    fi
fi

# Check for existing organization
if [ -f "$ORG_FILE" ]; then
    if [ "$OVERWRITE" = false ]; then
        log_warn "Organization '$ORG_NAME' already exists at '$ORG_FILE'"
        log_warn "Use --overwrite to replace it"
        exit 1
    else
        log_warn "Overwriting existing organization: $ORG_FILE"
    fi
fi

# Create new organization entry from template
if [ "$DRY_RUN" = false ]; then
    if ! cp "$TEMPLATE_FILE" "$ORG_FILE"; then
        log_error "Failed to copy template to '$ORG_FILE'"
        exit 1
    fi
    log_info "Created organization file: $ORG_FILE"

    # Update template placeholders with organization name
    # Use cross-platform sed syntax
    if command -v gsed >/dev/null 2>&1; then
        SED_CMD="gsed"
    else
        SED_CMD="sed"
    fi

    if ! $SED_CMD -i.bak "s|# Organization Template|# $ORG_NAME|" "$ORG_FILE"; then
        log_error "Failed to update title in '$ORG_FILE'"
        exit 1
    fi
    
    if ! $SED_CMD -i.bak "s|- \*\*Name:\*\* |- **Name:** $ORG_NAME|" "$ORG_FILE"; then
        log_error "Failed to update name in '$ORG_FILE'"
        exit 1
    fi

    # Remove backup files created by sed
    rm -f "$ORG_FILE.bak"

    log_info "Updated organization name in template"
else
    log_info "Would create organization file: $ORG_FILE"
    log_info "Would update template with organization name: $ORG_NAME"
fi

# Display completion message
if [ "$DRY_RUN" = false ]; then
    log_info "Organization creation complete!"
else
    log_info "Dry run complete - no files were created"
fi