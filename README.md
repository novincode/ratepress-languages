# RatePress Translations 🌍

Community translations for RatePress WordPress plugin.

## 🚀 Quick Start

1. Copy `ratepress.pot` to your local RatePress `languages/` folder
2. Create PO: `./script/generate-po.sh es_ES`
3. Translate the PO file with Poedit
4. Generate MO: `./script/generate-mo.sh es_ES`
5. Generate JSON: `./script/generate-json.sh es_ES`
6. Test locally in WordPress
7. Push to this repo!

## 📁 Files

- `ratepress.pot` - Template
- `ratepress-{locale}.po` - Your translations
- `ratepress-{locale}.mo` - Compiled
- `ratepress-admin-{locale}-1.0.0.json` - JS translations
- `languages.json` - Available languages

## 🛠 Tools

```bash
./script/generate-po.sh es_ES    # Create PO from POT
./script/generate-mo.sh es_ES    # Generate MO from PO
./script/generate-json.sh es_ES  # Generate JSON from PO
```

## 🔗 Links

- [RatePress Plugin](https://github.com/novincode/wp-ratepress)
