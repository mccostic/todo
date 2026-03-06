#!/bin/bash

echo "Running tests with coverage..."
flutter test --coverage

echo "Filtering generated files..."
lcov \
  --remove coverage/lcov.info \
  '**/*.mocks.dart' \
  '**/*.g.dart' \
  '*/injection_container.dart' \
  '**/screens/**' \
  '**/widgets/**' \
  '**/main.dart' \
  -o coverage/lcov_filtered.info

echo "Generating HTML report..."
genhtml coverage/lcov_filtered.info -o coverage/html

echo "Opening report..."
open coverage/html/index.html