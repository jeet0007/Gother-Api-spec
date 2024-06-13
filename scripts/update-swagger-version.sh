#!/bin/sh

# Extract current version
CURRENT_VERSION=$(grep "version:" swagger.yaml | awk '{print $2}')
echo "Current Swagger Version: $CURRENT_VERSION"

# Increment version (example logic to increment the patch version)
IFS='.' read -r -a version_parts <<< "$CURRENT_VERSION"
((version_parts[2]++))
NEW_VERSION="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"
echo "New Swagger Version: $NEW_VERSION"

# Update swagger.yaml with the new version
sed -i.bak "s/version: .*/version: $NEW_VERSION/" swagger.yaml

# Remove backup file created by sed
rm swagger.yaml.bak

# Add the updated file to git
git add swagger.yaml
