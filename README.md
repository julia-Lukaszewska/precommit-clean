


##  `safe-commit/README.md` 


#  safe-commit

`safe-commit.js` is a commit helper script that removes inline comments marked as `//#PL: ... #/` **before committing**, and **restores them locally** afterward.

This allows you to:
- keep personal or temporary notes in your working directory
- make clean commits to your Git history (e.g., for GitHub)
- avoid accidentally pushing internal comments

---

##  Folder structure

```md

safe-commit/
├── safe-commit.js           ← main logic
├── cleaner-config.json      ← patterns for removing comments
└── README.md                ← this file

```

---

##  Setup

1. Copy the `safe-commit/` folder into your project root
2. Add to your `package.json`:

```json
"scripts": {
  "safe-commit": "node safe-commit/safe-commit.js"
}
```

3. Ensure your `package.json` includes:

```json
"type": "module"
```

(if you're using ES modules)

---

##  Usage

```bash
# Stage changes
git add .

# Make a safe commit without Polish inline comments
npm run safe-commit -- --message "feat: added button component"
```

>  Comments will be removed from the commit, but restored in your working files immediately after.

---

##  What gets removed?

Only text **between the tags**:

```
  //#PL: temporary note #/
```

Supported in all comment types:

* `//` (inline)
* `/* */` (block)
* `{/* */}` (JSX)
* `<!-- -->` (HTML)

Examples:

```js
const x = 1;  //#PL: remove this #/

{/* //#PL: dev only #/ */}

<!-- //#PL: temp note #/ -->
```

---

##  What stays?

* Comments without `//#PL:` are left untouched
* Comments with `//#PL:` are stripped **from the commit only**
* Local files remain unchanged after the commit

---

##  CLI Options

| Flag            | Description                                         |
| --------------- | --------------------------------------------------- |
| `--message`     |  Required commit message (`git commit -m "..."`)  |
| `--dry-run`     |  Show what would be removed (no actual changes)   |
| `--staged-only` |  Only process staged files (added with `git add`) |

---

##  Also removes empty comments

After removing the `//#PL:` parts, it also cleans up empty comments like:

* `/* */`
* `{ }`
* `<!-- -->`

The logic is defined in `cleaner-config.json`.

---

##  Example config

```json
{
  "extensions": ["js", "ts", "jsx", "tsx", "html", "css"],
  "tagPatterns": [
    "//#PL:.*?#\\/",
    "/\\*\\s*//#PL:.*?#\\/\\s*\\*/",
    "(?<=/\\*[^]*?)//#PL:.*?#\\/(?=[^]*?\\*/)",
    "<!--\\s*//#PL:.*?#\\/\\s*-->",
    "(?<=<!--[^]*?)//#PL:.*?#\\/(?=[^]*?-->)",
    "\\{\\/\\*\\s*//#PL:.*?#\\/\\s*\\*\\/\\}",
    "(?<=\\{\\/\\*[^]*?)//#PL:.*?#\\/(?=[^]*?\\*\\/\\})"
  ],
  "emptyCommentPatterns": [
    "/\\*\\s*\\*/",
    "\\{\\s*\\}",
    "<!--\\s*-->"
  ]
}
```

---

##  Status

Fully tested on `.js`, `.jsx`, `.html`, `.css`
Works on Windows and macOS, fully compatible with Git + VS Code

---








