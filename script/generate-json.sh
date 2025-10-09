#!/bin/bash
# Generate JSON file from PO for React/JS translations
# Usage: ./generate-json.sh fa_IR

set -e

LOCALE=${1}
VERSION="1.0.0"

if [ -z "$LOCALE" ]; then
  echo "Usage: $0 <locale>  # Example: $0 fa_IR"
  exit 1
fi

LANG_DIR="languages/$LOCALE"
PO_FILE="$LANG_DIR/ratepress-$LOCALE.po"
JSON_FILE="$LANG_DIR/ratepress-admin-$LOCALE-$VERSION.json"

if [ ! -f "$PO_FILE" ]; then
  echo "❌ $PO_FILE not found"
  exit 1
fi

echo "Generating JSON for $LOCALE..."

LOCALE=$LOCALE VERSION=$VERSION node << 'NODEJS'
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
            if (currentMsgid && currentMsgstr) {
                translations[currentMsgid] = [currentMsgstr];
            }
            currentMsgid = line.slice(7, -1);
            currentMsgstr = '';
            isMultilineMsgid = true;
            isMultilineMsgstr = false;
        } else if (line.startsWith('msgstr "')) {
            currentMsgstr = line.slice(8, -1);
            isMultilineMsgid = false;
            isMultilineMsgstr = true;
        } else if (line.startsWith('"') && line.endsWith('"')) {
            const content = line.slice(1, -1);
            if (isMultilineMsgid) {
                currentMsgid += content;
            } else if (isMultilineMsgstr) {
                currentMsgstr += content;
            }
        } else if (line === '' || line.startsWith('#')) {
            if (currentMsgid && currentMsgstr) {
                translations[currentMsgid] = [currentMsgstr];
                currentMsgid = '';
                currentMsgstr = '';
            }
            isMultilineMsgid = false;
            isMultilineMsgstr = false;
        }
    }
    
    if (currentMsgid && currentMsgstr) {
        translations[currentMsgid] = [currentMsgstr];
    }
    
    delete translations[''];
    return translations;
}

const locale = process.env.LOCALE;
const version = process.env.VERSION || '1.0.0';
const poFile = `languages/${locale}/ratepress-${locale}.po`;
const jsonFile = `languages/${locale}/ratepress-admin-${locale}-${version}.json`;

const poContent = fs.readFileSync(poFile, 'utf8');
const translations = parsePOFile(poContent);

const jsonData = {
    "translation-revision-date": new Date().toISOString(),
    "generator": "RatePress JSON Generator",
    "source": poFile,
    "domain": "ratepress",
    "locale_data": {
        "ratepress": {
            "": {
                "domain": "ratepress",
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
