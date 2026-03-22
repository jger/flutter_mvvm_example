#!/usr/bin/env node
'use strict';
const fs = require('fs');
const path = require('path');
const version = process.argv[2];
if (!version) {
  console.error('usage: bump-pubspec-version.js <semver>');
  process.exit(1);
}
const pub = path.join(__dirname, '..', 'app', 'pubspec.yaml');
let s = fs.readFileSync(pub, 'utf8');
s = s.replace(/^version:\s*.+$/m, `version: ${version}`);
fs.writeFileSync(pub, s);
console.log(`Bumped app/pubspec.yaml to ${version}`);
