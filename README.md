# precommit-tag-cleaner

Git pre-commit hook that automatically removes tagged comments (e.g. `//#PL: ... #/`) from staged files before committing.

---

## How it works

This hook:

1. Collects staged files (`git diff --cached`),
2. Removes tagged comments (e.g. `//#PL:`),
3. Removes leftover empty comments and lines,
4. Adds the cleaned version to the commit,
5. Restores your local version — so your working files remain **unchanged**.

---

## Installation

1. Clone this repo or copy the `hooks/` folder to the root of your project.
2. Tell Git to use the custom hook path:

   ```bash
   git config core.hooksPath hooks
   ```

3. Make sure the `hooks/pre-commit` file is executable:

   ```bash
   chmod +x hooks/pre-commit   # For Linux/macOS only
   ```

---

## Tag configuration

Edit the `cleaner-config.json` file in the project root directory.

To add new comment tags (e.g. `//#DEBUG:`), see the config guide:
 [README_config.md](./README_config.md)

---

## Testing the cleaner

Test files and a script are located in the `test/` folder:

```powershell
./test/run-test.ps1
```

The script will:

- Run the same cleaning logic as the hook,
- Compare the result with `expected_output.*` files,
- Show a table of differences if something fails,
- Save the actual cleaned output to `test/output/actual_output.*` for inspection.

You can compare these outputs manually or with a diff tool.

---

## Run tests via npm

If you want to run the test script with `npm`:

1. Create a `package.json` file in the root folder:

   ```bash
   npm init -y
   ```

2. Add this to your `package.json`:
   - For Windows (default PowerShell):

     ```json
     "scripts": {
       "test": "powershell -ExecutionPolicy Bypass -File ./test/run-test.ps1"
     }
     ```

   - For macOS/Linux (with PowerShell Core installed):

     ```json
     "scripts": {
       "test": "pwsh ./test/run-test.ps1"
     }
     ```

3. Run tests using:

   ```bash
   npm run test
   ```

Make sure the correct PowerShell (`powershell` or `pwsh`) is available in your environment. (`pwsh`) installed and accessible from your terminal.

---

## Supported file types

All file extensions listed in `cleaner-config.json`, e.g.:

- `.js`, `.jsx`, `.ts`, `.tsx`
- `.html`, `.css`, `.json`, `.yml`, `.yaml`, `.md`

---

## Example

From:

```js
const x = 1;  //#PL: temporary comment #/
```

To:

```js
const x = 1;
```

---

## Note

Comments are removed **only from staged files**.

Your local files stay **unchanged** — the hook restores originals after staging the cleaned version.
