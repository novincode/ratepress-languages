#!/bin/bash
# Generate/Update PO file from POT (preserves existing translations)
# Usage: ./generate-po.sh fa_IR

set -e

LOCALE=${1}
DOMAIN="ratepress"

if [ -z "$LOCALE" ]; then
  echo "Usage: $0 <locale>  # Example: $0 fa_IR"
  exit 1
fi

# Check if POT exists
if [ ! -f "languages/$DOMAIN.pot" ]; then
  echo "❌ languages/$DOMAIN.pot not found. Run the main generate-pot.sh first."
  exit 1
fi

# Create language directory if it doesn't exist
LANG_DIR="languages/$LOCALE"
mkdir -p "$LANG_DIR"

PO_FILE="$LANG_DIR/$DOMAIN-$LOCALE.po"

# Check if PO file already exists
if [ -f "$PO_FILE" ]; then
  echo "Merging new strings into existing PO file (preserving translations)..."
  
  # Use msgmerge to merge POT into PO (preserves existing translations)
  if command -v msgmerge &> /dev/null; then
    msgmerge --update --backup=off "$PO_FILE" "languages/$DOMAIN.pot"
    echo "✅ Merged new strings while preserving existing translations in $PO_FILE"
  else
    echo "❌ msgmerge not found. Install gettext tools:"
    echo "   macOS: brew install gettext"
    echo "   Ubuntu: sudo apt-get install gettext"
    exit 1
  fi
else
  echo "Creating new PO file from POT..."
  
  # Create new PO file from POT using msginit
  if command -v msginit &> /dev/null; then
    msginit --input="languages/$DOMAIN.pot" --locale=$LOCALE --output="$PO_FILE" --no-translator
    echo "✅ Created new $PO_FILE"
    echo "📝 Edit this file with Poedit or any PO editor to add translations"
  else
    echo "❌ msginit not found. Install gettext tools:"
    echo "   macOS: brew install gettext"
    echo "   Ubuntu: sudo apt-get install gettext"
    exit 1
  fi
fi

# Add a comment section for untranslated strings at the bottom
if command -v msgattrib &> /dev/null; then
  UNTRANSLATED_COUNT=$(msgattrib --untranslated "$PO_FILE" | grep -c "^msgid " || echo "0")
  if [ "$UNTRANSLATED_COUNT" -gt 1 ]; then  # More than just the header
    echo ""
    echo "📝 Found $((UNTRANSLATED_COUNT - 1)) untranslated strings"
    echo "   Use Poedit or search for empty msgstr \"\" to find them"
  fi
fi
