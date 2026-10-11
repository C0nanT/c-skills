#!/usr/bin/env bash
# The ordered list of checks. Source this file; do not run it.
# Shared by scripts/validate.sh and tests/validate-checks.sh.
CHECKS=(
  frontmatter
  readme-public
  readme-private
  readme-links
  bucket-readmes
  plugin-json
  bucket-readme-disk
  markdownlint
  invocation-mode
  setup-skills-merge
  wizard-write-env
  spec-file-name
  stale-router
  untrusted-data
  stale-translation
)
