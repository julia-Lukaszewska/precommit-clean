# How to configure `cleaner-config.json`

The `cleaner-config.json` file contains the settings that tell the PowerShell script (`pre-commit.ps1`) which files to check and what comment tags to remove before committing.

---

## Section: `"extensions"`

This is a list of file extensions that the hook will process.

### Example

```json
"extensions": ["js", "jsx", "html", "css"]
```

### To add a new extension

Just add it to the list:

```json
"extensions": ["js", "jsx", "html", "css", "vue"]
```

---

## Section: `"tagPatterns"`

This is a list of **regular expressions** used to match tagged comments, e.g. `//#PL:`.

### Example

```json
"tagPatterns": [
  "//#PL:.*?#\\/",
  "/\\*.*?//#PL:.*?#\\/.*?\\*/"
]
```

### To add a new tag (e.g. `//#DEBUG:`)

Just insert a new regex:

```json
"//#DEBUG:.*?#\\/"
```

Remember: in JSON you must escape backslashes (`\\`).

---

## Section: `"emptyCommentPatterns"`

These patterns detect **empty comments** that may remain after removing tagged content.

### Example

```json
"emptyCommentPatterns": [
  "/\\*\\s*\\*/",
  "\\{\\s*\\}",
  "<!--\\s*-->"
]
```

You usually don't need to modify these unless you're adding new comment formats.

---

## Additional Tips

- The `cleaner-config.json` file must be placed **in the root of the repository** (same level as `.git`, not in `hooks`).
- No need to restart VS Code after changes.
- Always test your regexes on a small sample to avoid accidental removals.
