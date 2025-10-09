#!/bin/bash
# Generate PO file from POT for a new locale
# Usage: ./generate-po.sh es_ES

set -e

LOCALE=${1}

if [ -z "$LOCALE" ]; then
  echo "Usage: $0 <locale>  # Example: $0 es_ES"
  exit 1
fi

# Check if POT exists
if [ ! -f "ratepress.pot" ]; then
  echo "❌ ratepress.pot not found. Run the main generate-pot.sh first."
  exit 1
fi

# Create language directory if it doesn't exist
LANG_DIR="languages/$LOCALE"
mkdir -p "$LANG_DIR"

# Create PO file from POT
if command -v msginit &> /dev/null; then
  msginit --input=ratepress.pot --locale=$LOCALE --output="$LANG_DIR/ratepress-$LOCALE.po" --no-translator
  echo "✅ Created $LANG_DIR/ratepress-$LOCALE.po"
  echo "📝 Edit this file with Poedit or any PO editor to add translations"
else
  echo "❌ msginit not found. Install gettext tools:"
  echo "   macOS: brew install gettext"
  echo "   Ubuntu: sudo apt-get install gettext"
  exit 1
fi
