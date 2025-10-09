#!/bin/bash
# Generate MO file from PO
# Usage: ./generate-mo.sh fa_IR

set -e

LOCALE=${1}

if [ -z "$LOCALE" ]; then
  echo "Usage: $0 <locale>  # Example: $0 fa_IR"
  exit 1
fi

PO_FILE="ratepress-$LOCALE.po"

if [ ! -f "$PO_FILE" ]; then
  echo "❌ $PO_FILE not found"
  exit 1
fi

# Generate MO file
if command -v msgfmt &> /dev/null; then
  msgfmt $PO_FILE -o ratepress-$LOCALE.mo
  echo "✅ Generated ratepress-$LOCALE.mo"
else
  echo "❌ msgfmt not found. Install gettext tools:"
  echo "   macOS: brew install gettext"
  echo "   Ubuntu: sudo apt-get install gettext"
  exit 1
fi
