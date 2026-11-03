#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$APP_DIR/.." && pwd)"
OUTPUT_DIR="$APP_DIR/dist"
UNIVERSAL=false
VERSION="$(sed -n 's/^VERSION="\([^"]*\)"$/\1/p' "$REPO_DIR/mole" | head -1)"

[[ -n "$VERSION" ]] || {
    echo "Could not read VERSION from mole" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --universal)
            UNIVERSAL=true
            shift
            ;;
        --output)
            [[ -n "${2:-}" ]] || {
                echo "Missing path after --output" >&2
                exit 2
            }
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 2
            ;;
    esac
done

mkdir -p "$OUTPUT_DIR"
APP_BUNDLE="$OUTPUT_DIR/Mole 中文版.app"
if [[ -e "$APP_BUNDLE" ]]; then
    if [[ ! -f "$APP_BUNDLE/Contents/Info.plist" ]] ||
        [[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_BUNDLE/Contents/Info.plist" 2> /dev/null || true)" != "fit.mole.chinese-cli-app" ]]; then
        echo "Refusing to replace an app bundle that is not Mole 中文版: $APP_BUNDLE" >&2
        exit 1
    fi
fi
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

if [[ "$UNIVERSAL" == "true" ]]; then
    for ARCH in arm64 x86_64; do
        TRIPLE="$ARCH-apple-macosx14.0"
        SCRATCH="$APP_DIR/.build-$ARCH"
        swift build --package-path "$APP_DIR" --scratch-path "$SCRATCH" \
            --configuration release --triple "$TRIPLE" --product MoleApp
        mkdir -p "$APP_DIR/.app-binaries/$ARCH"
        BINARY="$SCRATCH/$ARCH-apple-macosx/release/MoleApp"
        if [[ ! -f "$BINARY" ]]; then
            BINARY="$(find "$SCRATCH" -type f -path '*/release/MoleApp' -print -quit)"
        fi
        [[ -f "$BINARY" ]] || {
            echo "Built MoleApp binary not found for $ARCH" >&2
            exit 1
        }
        cp "$BINARY" "$APP_DIR/.app-binaries/$ARCH/MoleApp"
    done
    lipo -create \
        "$APP_DIR/.app-binaries/arm64/MoleApp" \
        "$APP_DIR/.app-binaries/x86_64/MoleApp" \
        -output "$APP_BUNDLE/Contents/MacOS/MoleApp"
else
    swift build --package-path "$APP_DIR" --configuration release --product MoleApp
    cp "$APP_DIR/.build/release/MoleApp" "$APP_BUNDLE/Contents/MacOS/MoleApp"
fi

cp "$APP_DIR/Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "$REPO_DIR/LICENSE" "$APP_BUNDLE/Contents/Resources/LICENSE"

ICON_SOURCE="$REPO_DIR/plugins/mole/.claude-plugin/icon.png"
if [[ -f "$ICON_SOURCE" ]] && command -v iconutil > /dev/null 2>&1; then
    ICONSET="$APP_DIR/.build/Mole.iconset"
    mkdir -p "$ICONSET"
    sips -z 16 16 "$ICON_SOURCE" --out "$ICONSET/icon_16x16.png" > /dev/null
    sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET/icon_16x16@2x.png" > /dev/null
    sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET/icon_32x32.png" > /dev/null
    sips -z 64 64 "$ICON_SOURCE" --out "$ICONSET/icon_32x32@2x.png" > /dev/null
    sips -z 128 128 "$ICON_SOURCE" --out "$ICONSET/icon_128x128.png" > /dev/null
    sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET/icon_128x128@2x.png" > /dev/null
    sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET/icon_256x256.png" > /dev/null
    sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET/icon_256x256@2x.png" > /dev/null
    cp "$ICON_SOURCE" "$ICONSET/icon_512x512.png"
    sips -z 1024 1024 "$ICON_SOURCE" --out "$ICONSET/icon_512x512@2x.png" > /dev/null
    iconutil -c icns "$ICONSET" -o "$APP_BUNDLE/Contents/Resources/Mole.icns"
    /usr/libexec/PlistBuddy -c 'Add :CFBundleIconFile string Mole' "$APP_BUNDLE/Contents/Info.plist"
fi

/usr/libexec/PlistBuddy -c 'Set :CFBundleExecutable MoleApp' "$APP_BUNDLE/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP_BUNDLE/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$APP_BUNDLE/Contents/Info.plist"
chmod +x "$APP_BUNDLE/Contents/MacOS/MoleApp"
codesign --force --deep --sign - "$APP_BUNDLE"

ZIP_PATH="$OUTPUT_DIR/Mole-zh-macOS-universal.zip"
if [[ "$UNIVERSAL" == "true" ]]; then
    ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$ZIP_PATH"
fi

echo "Built: $APP_BUNDLE"
if [[ -f "$ZIP_PATH" ]]; then
    echo "Packaged: $ZIP_PATH"
fi
