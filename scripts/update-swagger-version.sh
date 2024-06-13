#!/bin/sh

# Extract current version from package.json
PACKAGE_VERSION=$(grep '"version"' package.json | awk -F: '{ print $2 }' | sed 's/[", ]//g')
echo "Current Package Version: $PACKAGE_VERSION"

# Extract current version from swagger.yaml
SWAGGER_VERSION=$(grep "version:" swagger.yaml | awk '{print $2}')
echo "Current Swagger Version: $SWAGGER_VERSION"

# Function to compare versions
compare_versions () {
    if [ "$1" = "$2" ]; then
        return 0
    fi

    IFS='.' read -r -a version1 <<< "$1"
    IFS='.' read -r -a version2 <<< "$2"

    for ((i = 0; i < 3; i++)); do
        if [ "${version1[$i]}" -lt "${version2[$i]}" ]; then
            return 2
        elif [ "${version1[$i]}" -gt "${version2[$i]}" ]; then
            return 1
        fi
    done

    return 0
}

# Increment version (example logic to increment the patch version)
increment_version () {
    IFS='.' read -r -a version_parts <<< "$1"
    version_parts[2]=$(expr ${version_parts[2]} + 1)
    echo "${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"
}

# Compare versions
compare_versions $PACKAGE_VERSION $SWAGGER_VERSION
result=$?

if [ $result -eq 1 ]; then
    # package.json version is higher
    NEW_VERSION=$PACKAGE_VERSION
    sed -i.bak "s/version: .*/version: $NEW_VERSION/" swagger.yaml
    rm swagger.yaml.bak
    git add swagger.yaml
elif [ $result -eq 2 ]; then
    # swagger.yaml version is higher
    NEW_VERSION=$SWAGGER_VERSION
    sed -i.bak "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" package.json
    rm package.json.bak
    git add package.json
else
    # Versions are equal, increment the version in package.json
    NEW_VERSION=$(increment_version $PACKAGE_VERSION)
    sed -i.bak "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" package.json
    sed -i.bak "s/version: .*/version: $NEW_VERSION/" swagger.yaml
    rm package.json.bak
    rm swagger.yaml.bak
    git add package.json swagger.yaml
fi

echo "Updated Version: $NEW_VERSION"
