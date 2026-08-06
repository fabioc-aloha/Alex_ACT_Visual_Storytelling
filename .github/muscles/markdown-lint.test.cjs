'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');
const { lint } = require('./markdown-lint.cjs');

test('independent tables with different widths do not conflict', () => {
  const markdown = '# Tables\n\n| A | B |\n| --- | --- |\n| 1 | 2 |\n\nText.\n\n| C | D | E |\n| --- | --- | --- |\n| 3 | 4 | 5 |\n';
  const result = lint(markdown, { target: 'word' });
  assert.equal(result.errors.some((error) => error.id === 'TBL001'), false);
});

test('a malformed table block still fails', () => {
  const markdown = '# Table\n\n| A | B |\n| --- | --- |\n| 1 | 2 | 3 |\n';
  const result = lint(markdown, { target: 'word' });
  assert.equal(result.errors.some((error) => error.id === 'TBL001'), true);
});

test('Mermaid init directives are skipped before diagram type detection', () => {
  const markdown = '# Diagram\n\n```mermaid\n%%{init: {"theme":"base"}}%%\n%% a comment\nflowchart LR\n  A --> B\n```\n';
  const result = lint(markdown, { target: 'word' });
  assert.equal(result.errors.some((error) => error.id === 'MMD001'), false);
});

test('an invalid Mermaid diagram type still fails', () => {
  const markdown = '# Diagram\n\n```mermaid\n%% comment\nnotARealDiagram\n```\n';
  const result = lint(markdown, { target: 'word' });
  assert.equal(result.errors.some((error) => error.id === 'MMD001'), true);
});
