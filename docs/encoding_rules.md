# PBIT File Encoding Rules

A `.pbit` Power BI Template file is a ZIP archive. Getting the encoding wrong
on any file produces "corrupted or encrypted" errors with no useful detail.

These rules were determined by comparing a machine-generated file against
a real `.pbit` exported by Power BI Desktop March 2026 (2.152.x).

## File Encoding Table

| File | Encoding | BOM | Notes |
|---|---|---|---|
| `Version` | UTF-16-LE | ❌ None | Plain `1.28` as UTF-16-LE bytes |
| `DataModelSchema` | UTF-16-LE | ❌ None | Pretty-printed JSON with \r\n |
| `Report/Layout` | UTF-16-LE | ❌ None | Pretty-printed JSON with \r\n |
| `DiagramLayout` | UTF-16-LE | ❌ None | Pretty-printed JSON |
| `Settings` | UTF-16-LE | ❌ None | Compact JSON |
| `Metadata` | UTF-16-LE | ❌ None | Compact JSON |
| `[Content_Types].xml` | UTF-8 | ✅ UTF-8 BOM (`\xef\xbb\xbf`) | Only file requiring a BOM |
| `SecurityBindings` | Binary (DPAPI) | N/A | Must be copied from real PBIT |
| Theme JSON | UTF-8 | ❌ None | Copy from real PBIT |

## Critical Rules

1. **`[Content_Types].xml` MUST have a UTF-8 BOM** — without it, PBI rejects the file
2. **All other JSON files must NOT have any BOM** — a UTF-16 BOM causes `﻿` to appear as the first character, breaking JSON parsing
3. **`SecurityBindings` is DPAPI-encrypted** — you cannot generate it; copy from an existing `.pbit` file saved by Power BI Desktop on the same machine
4. **`compatibilityLevel` must match your PBI version** — March 2026 requires `1600`
5. **DataModelSchema uses `\r\n` line endings** — use `json.dumps(..., indent=2).replace('\n', '\r\n')`
6. **Each column needs `lineageTag` (UUID), `summarizeBy`, and `annotations`** — missing these causes `MashupValidationError`

## Python encoding helper

```python
def utf16(s):
    # NO BOM — PBI rejects BOM on JSON files
    return s.encode('utf-16-le')

def utf8_bom(s):
    # WITH BOM — required for Content_Types.xml only
    return b'\xef\xbb\xbf' + s.encode('utf-8')
```

## Recommended approach

Clone all files from a known-good `.pbit` file and replace only `DataModelSchema`:

```python
with zipfile.ZipFile('source.pbit') as zin:
    files = {name: zin.read(name) for name in zin.namelist()}

files['DataModelSchema'] = new_schema_str.encode('utf-16-le')

with zipfile.ZipFile('output.pbit', 'w', zipfile.ZIP_DEFLATED) as zout:
    for name, data in files.items():
        zout.writestr(name, data)
```
