# Contributing Translations

## Steps

1. Fork this repo
2. Create/edit PO file for your language
3. Generate MO and JSON files
4. Test in WordPress
5. Update `languages.json`
6. Submit PR

## Using the Scripts

```bash
# Create new translation
./script/generate-po.sh es_ES

# Edit with Poedit or any PO editor
poedit ratepress-es_ES.po

# Generate binary files
./script/generate-mo.sh es_ES
./script/generate-json.sh es_ES
```

## Update languages.json

```json
{
  "languages": {
    "es_ES": {
      "name": "Español",
      "native_name": "Español",
      "translators": ["@yourname"],
      "completion": 100,
      "last_updated": "2025-01-10"
    }
  }
}
```

## Questions?

Open an issue or PR!
