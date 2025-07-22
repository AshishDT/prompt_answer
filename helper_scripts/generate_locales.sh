#!/bin/bash

# Resolve the root of the project dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT" || exit 1

LOCALES_DIR="assets/locales"

if [ ! -d "$LOCALES_DIR" ]; then
  echo "✖  + $LOCALES_DIR directory does not exist."
  exit 1
fi

echo "📦  Generating locale files..."

get generate locales "$LOCALES_DIR"
