#!/bin/bash
# Generate JSON file from PO for React/JS translations
# Usage: ./generate-json.sh fa_IR [version]

set -e

LOCALE=${1}
VERSION=${2:-"1.0.0"}  # Default to 1.0.0 if not provided
DOMAIN="ratepress"

if [ -z "$LOCALE" ]; then
  echo "Usage: $0 <locale> [version]  # Example: $0 fa_IR 1.0.0"
  exit 1
fi

LANG_DIR="languages/$LOCALE"
PO_FILE="$LANG_DIR/$DOMAIN-$LOCALE.po"
JSON_FILE="$LANG_DIR/$DOMAIN-admin-$LOCALE-$VERSION.json"

if [ ! -f "$PO_FILE" ]; then
  echo "❌ $PO_FILE not found"
  exit 1
fi

echo "Generating JSON for $LOCALE (version: $VERSION)..."

LOCALE=$LOCALE VERSION=$VERSION DOMAIN=$DOMAIN node << 'NODEJS'
const fs = require('fs');
const path = require('path');

function parsePOFile(poContent) {
    const translations = {};
    const lines = poContent.split('\n');
    let currentMsgid = '';
    let currentMsgstr = '';
    let isMultilineMsgid = false;
    let isMultilineMsgstr = false;
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        
        if (line.startsWith('msgid "')) {
            // Save previous entry if exists
            if (currentMsgid && currentMsgstr) {
                translations[currentMsgid] = [currentMsgstr];
            }
            
            // Start new msgid
            currentMsgid = line.slice(7, -1);
            currentMsgstr = '';
            isMultilineMsgid = true;
            isMultilineMsgstr = false;
        } else if (line.startsWith('msgstr "')) {
            currentMsgstr = line.slice(8, -1);
            isMultilineMsgid = false;
            isMultilineMsgstr = true;
        } else if (line.startsWith('"') && line.endsWith('"')) {
            // Continuation line
            const content = line.slice(1, -1);
            if (isMultilineMsgid) {
                currentMsgid += content;
            } else if (isMultilineMsgstr) {
                currentMsgstr += content;
            }
        } else if (line === '' || line.startsWith('#')) {
            // End of entry or comment
            if (currentMsgid && currentMsgstr) {
                translations[currentMsgid] = [currentMsgstr];
                currentMsgid = '';
                currentMsgstr = '';
            }
            isMultilineMsgid = false;
            isMultilineMsgstr = false;
        }
    }
    
    // Save last entry
    if (currentMsgid && currentMsgstr) {
        translations[currentMsgid] = [currentMsgstr];
    }
    
    // Remove empty string key
    delete translations[''];
    
    return translations;
}

const locale = process.env.LOCALE;
const version = process.env.VERSION || '1.0.0';
const domain = process.env.DOMAIN || 'ratepress';
const poFile = `languages/${locale}/${domain}-${locale}.po`;
const jsonFile = `languages/${locale}/${domain}-admin-${locale}-${version}.json`;

if (!fs.existsSync(poFile)) {
    console.error(`❌ PO file not found: ${poFile}`);
    process.exit(1);
}

const poContent = fs.readFileSync(poFile, 'utf8');
const translations = parsePOFile(poContent);

// Create JSON structure
const jsonData = {
    "translation-revision-date": new Date().toISOString(),
    "generator": "RatePress JSON Generator",
    "source": poFile,
    "domain": domain,
    "locale_data": {
        [domain]: {
            "": {
                "domain": domain,
                "lang": locale,
                "plural-forms": "nplurals=2; plural=(n==0 || n==1);"
            },
            ...translations
        }
    }
};

fs.writeFileSync(jsonFile, JSON.stringify(jsonData, null, 4));
console.log(`✅ Generated ${jsonFile} with ${Object.keys(translations).length} translations`);
NODEJS
