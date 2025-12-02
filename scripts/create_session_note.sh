#!/bin/bash

# create_session_note.sh
# Script to create session notes with flexible options
#
# Usage: ./create_session_note.sh [OPTIONS]
# - Creates a new session note using the Session Notes template
# - Automatically determines next session number or uses provided number
# - Uses today's date or provided date
# - Session numbers increment automatically based on existing files
#
# Requirements:
# - Template file: template/Session Notes.md
# - Sessions directory will be created if it doesn't exist
#
# Output:
# - Creates Session-X.md in Sessions/ directory
# - Prints status messages to stdout

set -e

# Default values
DRY_RUN=false
VERBOSE=false
QUIET=false
FORCE=false
SESSION_NUMBER=""
SESSION_DATE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory and base paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
SESSION_DIR="$BASE_DIR/Sessions"
TEMPLATE_FILE="$SCRIPT_DIR/template/Session Notes.md"

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Create a new session note from template."
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -d, --dry-run   Show what would be created without creating files"
    echo "  -v, --verbose   Show detailed output"
    echo "  -q, --quiet     Suppress output (except errors)"
    echo "  -f, --force     Create session even if one exists for today"
    echo "  -n, --number N  Use specific session number instead of auto-detecting"
    echo "  -t, --date D    Use specific date (YYYY-MM-DD format) instead of today"
    echo ""
    echo "Examples:"
    echo "  $0                           # Create next session for today"
    echo "  $0 --dry-run                 # Preview what would be created"
    echo "  $0 --number 5 --date 2024-01-15  # Create Session 5 for specific date"
    echo "  $0 --force                   # Create session even if today's exists"
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
        -f|--force)
            FORCE=true
            shift
            ;;
        -n|--number)
            if [ -z "$2" ]; then
                log_error "Option $1 requires a session number"
                usage
            fi
            if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                log_error "Session number must be a positive integer"
                exit 1
            fi
            SESSION_NUMBER="$2"
            shift 2
            ;;
        -t|--date)
            if [ -z "$2" ]; then
                log_error "Option $1 requires a date"
                usage
            fi
            # Validate date format (YYYY-MM-DD)
            if ! [[ "$2" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                log_error "Date must be in YYYY-MM-DD format"
                exit 1
            fi
            # Validate if date is real (cross-platform)
            if ! date -j -f "%Y-%m-%d" "$2" >/dev/null 2>&1; then
                log_error "Invalid date: $2"
                exit 1
            fi
            SESSION_DATE="$2"
            shift 2
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            log_error "Unexpected argument: $1"
            usage
            ;;
    esac
done

# Set defaults if not provided
if [ -z "$SESSION_DATE" ]; then
    SESSION_DATE=$(date +"%Y-%m-%d")
fi

# Display what will be created
if [ "$DRY_RUN" = true ] || [ "$VERBOSE" = true ]; then
    echo "Creating session note..."
    echo "Sessions directory: $SESSION_DIR"
    echo "Template file: $TEMPLATE_FILE"
    echo "Session date: $SESSION_DATE"
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
if [ ! -w "$(dirname "$SESSION_DIR")" ] && [ ! -d "$SESSION_DIR" ]; then
    log_error "No write permission to create Sessions directory"
    exit 1
fi

if [ -d "$SESSION_DIR" ] && [ ! -w "$SESSION_DIR" ]; then
    log_error "No write permission to Sessions directory: $SESSION_DIR"
    exit 1
fi

# Ensure sessions directory exists
if [ ! -d "$SESSION_DIR" ]; then
    if [ "$DRY_RUN" = false ]; then
        if ! mkdir -p "$SESSION_DIR"; then
            log_error "Could not create Sessions directory '$SESSION_DIR'"
            exit 1
        fi
        log_info "Created Sessions directory: $SESSION_DIR"
    else
        log_info "Would create Sessions directory: $SESSION_DIR"
    fi
fi

# get_next_session_number()
# Determines the next available session number by scanning existing files
# Returns: The next session number (starting from 1 if none exist)
get_next_session_number() {
    if [ ! -d "$SESSION_DIR" ] || [ -z "$(ls -A "$SESSION_DIR" 2>/dev/null)" ]; then
        echo "1"
        return
    fi

    # Find existing session files and extract numbers
    local max_num=0
    for file in "$SESSION_DIR"/Session-*.md; do
        if [ -f "$file" ] && [[ "$file" =~ ^"$SESSION_DIR"/Session-[0-9]+\.md$ ]]; then
            local basename=$(basename "$file" .md)
            local num=$(echo "$basename" | sed 's/Session-//')
            # Ensure it's a pure number
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -gt "$max_num" ]; then
                max_num=$num
            fi
        fi
    done

    echo $((max_num + 1))
}

# check_session_exists_for_date()
# Checks if a session already exists for the given date
# Returns: 0 if exists, 1 if not exists
check_session_exists_for_date() {
    local check_date="$1"
    
    # Scan existing session files for the date
    for file in "$SESSION_DIR"/Session-*.md; do
        if [ -f "$file" ] && [[ "$file" =~ ^"$SESSION_DIR"/Session-[0-9]+\.md$ ]]; then
            if grep -q "^- \*\*Date:\*\* $check_date$" "$file"; then
                return 0  # Found
            fi
        fi
    done
    return 1  # Not found
}

# create_session_note(session_num, session_date)
# Creates a new session note file from the template
# Args: session_num - The session number to create
#       session_date - The date for the session
# Returns: 0 on success, 1 on failure
create_session_note() {
    local session_num=$1
    local session_date=$2
    local session_file="$SESSION_DIR/Session-$session_num.md"

    # Check if file already exists
    if [ -f "$session_file" ]; then
        log_warn "Session file already exists: $session_file"
        return 1
    fi

    # Copy template to new session file
    if [ "$DRY_RUN" = false ]; then
        if ! cp "$TEMPLATE_FILE" "$session_file"; then
            log_error "Failed to copy template to '$session_file'"
            return 1
        fi
        log_info "Created session file: $session_file"

        # Use cross-platform sed syntax
        if command -v gsed >/dev/null 2>&1; then
            SED_CMD="gsed"
        else
            SED_CMD="sed"
        fi

        # Update session file with provided information using safe delimiters
        if ! $SED_CMD -i.bak "s#- \*\*Session Number:\*\* #- **Session Number:** $session_num#" "$session_file"; then
            log_error "Failed to update session number in '$session_file'"
            return 1
        fi
        
        if ! $SED_CMD -i.bak "s#- \*\*Date:\*\* #- **Date:** $session_date#" "$session_file"; then
            log_error "Failed to update date in '$session_file'"
            return 1
        fi

        # Update the title
        if ! $SED_CMD -i.bak "s|# Session Notes Template|# Session $session_num Notes|" "$session_file"; then
            log_error "Failed to update title in '$session_file'"
            return 1
        fi

        # Remove backup files created by sed
        rm -f "$session_file.bak"

        log_info "Updated session with number $session_num and date $session_date"
    else
        log_info "Would create session file: $session_file"
        log_info "Would update with session number: $session_num"
        log_info "Would update with date: $session_date"
    fi

    return 0
}

# Main execution logic
log_info "Checking for existing session notes..."

# Determine session number
if [ -n "$SESSION_NUMBER" ]; then
    next_session="$SESSION_NUMBER"
    log_info "Using provided session number: $next_session"
else
    next_session=$(get_next_session_number)
    log_info "Auto-detected next session number: $next_session"
fi

# Check for existing session on the specified date
if check_session_exists_for_date "$SESSION_DATE"; then
    if [ "$FORCE" = false ]; then
        log_warn "Session note for date $SESSION_DATE already exists"
        log_warn "Use --force to create another session for the same date"
        exit 1
    else
        log_warn "Force mode: creating additional session for date $SESSION_DATE"
    fi
fi

# Create new session
log_info "Creating Session $next_session for date $SESSION_DATE..."
if ! create_session_note "$next_session" "$SESSION_DATE"; then
    log_error "Failed to create session note"
    exit 1
fi

# Display completion message
if [ "$DRY_RUN" = false ]; then
    log_info "Session note creation complete!"
else
    log_info "Dry run complete - no files were created"
fi