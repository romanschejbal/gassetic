#!/usr/bin/env node
require('babel-register');
const gassetic = require('./src').default;

gassetic();
