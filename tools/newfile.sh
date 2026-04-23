#!/bin/bash
# newfile.sh
# Generate a new file from a template, substituting filename and include guards.
#
# Usage: ./tools/newfile.sh <type> <name> [location]
#   type     : c | h | s | ld
#   name     : filename without extension
#   location : subdirectory to place the file in (optional, default: project root)
#
# Example: ./tools/newfile.sh c uart2 kernel

# --- Argument Parsing ------------------------------------------------------

TYPE=$1
NAME=$2
LOC=${3:-.}

TEMPLATE="tools/templates/template.$TYPE"
OUTDIR="$LOC"
OUTFILE="$OUTDIR/$NAME.$TYPE"

# --- Validation ------------------------------------------------------------

if [[ -z "$TYPE" || -z "$NAME" ]]; then
    echo "Usage: $0 <type> <name> [location]"
    echo "  Types: c | h | s | ld"
    exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
    echo "Error: template '$TEMPLATE' not found."
    exit 1
fi

if [[ -f "$OUTFILE" ]]; then
    echo "Error: '$OUTFILE' already exists. Aborting."
    exit 1
fi

# --- Create Output Directory -----------------------------------------------

mkdir -p "$OUTDIR"

# --- Copy and Substitute Template ------------------------------------------

cp "$TEMPLATE" "$OUTFILE"

# Replace template filename in header comment block
sed -i "s/template\.$TYPE/$NAME.$TYPE/g" "$OUTFILE"

# --- Header Guard for .h files ---------------------------------------------

if [[ "$TYPE" == "h" ]]; then
    GUARD=$(echo "${NAME}" | tr '[:lower:]' '[:upper:]' | tr '-' '_')_H
    sed -i "s/TEMPLATE_H/$GUARD/g" "$OUTFILE"
fi

echo "Created: $OUTFILE"
