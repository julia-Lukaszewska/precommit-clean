#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Parse CLI arguments
const args = process.argv.slice(2);
const options = {
  message: '',
  dryRun: false,
  stagedOnly: false,
};

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--message') options.message = args[++i];
  else if (args[i] === '--dry-run') options.dryRun = true;
  else if (args[i] === '--staged-only') options.stagedOnly = true;
}

// Validate commit message
if (!options.message && !options.dryRun) {
  console.error('Error: Commit message is required. Use --message "..."');
  process.exit(1);
}

const repoRoot = execSync('git rev-parse --show-toplevel').toString().trim();
const configPath = path.join(__dirname, 'cleaner-config.json');

if (!fs.existsSync(configPath)) {
  console.error('Error: cleaner-config.json not found.');
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const extensions = config.extensions || [];
const tagRx = new RegExp(config.tagPatterns.join('|'), 'gis');
const emptyRx = new RegExp(config.emptyCommentPatterns.join('|'), 'gm');

// Get list of staged files
const diffFilter = 'ACMRTUXB';
const rawFiles = execSync(`git diff --cached --name-only --diff-filter=${diffFilter}`)
  .toString()
  .trim()
  .split('\n')
  .filter(Boolean);

const files = rawFiles.filter((file) => {
  const ext = path.extname(file).replace('.', '');
  return extensions.includes(ext);
});

if (files.length === 0) {
  console.log('No matching files to process.');
  process.exit(0);
}

const backup = {};
let changesMade = false;

for (const file of files) {
  const fullPath = path.join(repoRoot, file);
  if (!fs.existsSync(fullPath)) continue;

  const original = fs.readFileSync(fullPath, 'utf8');
  const cleaned = original.replace(tagRx, '').replace(emptyRx, '');

  if (cleaned !== original) {
    changesMade = true;
    console.log(`Cleaned: ${file}`);
    if (!options.dryRun) {
      backup[file] = original;
      fs.writeFileSync(fullPath, cleaned, 'utf8');
    }
  }
}

if (options.dryRun) {
  console.log('Dry run complete. No files were changed.');
  process.exit(0);
}

if (!changesMade) {
  console.log('No changes to commit.');
  process.exit(0);
}

try {
  execSync(`git commit -m "${options.message}"`, { stdio: 'inherit' });
} catch (err) {
  console.error('Error: Git commit failed.');
  process.exit(1);
}

// Restore original files after commit
for (const file in backup) {
  fs.writeFileSync(path.join(repoRoot, file), backup[file], 'utf8');
}

console.log('Original files restored after commit.');
