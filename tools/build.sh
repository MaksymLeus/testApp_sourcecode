#!/usr/bin/env bash
set -euo pipefail

#========================================
# COLORS
#========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[1;34m'
NC='\033[0m'

#========================================
# CONFIGURATION
#========================================
PROJECT_NAME="awscli-addons"
SRC_DIR="awscli_addons"
DIST_DIR="dist"
BUILD_DIR="build"
ZIP_NAME="${PROJECT_NAME}.zip"
VERSION=$(git describe --tags --always 2>/dev/null || echo "dev")

#========================================
# HELP 
#========================================
# Helper for cross-platform sed in-place
sed_inplace() {
  local pattern="$1"
  local file="$2"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD sed)
    sed -i "" "$pattern" "$file"
  else
    # Linux (GNU sed)
    sed -i "$pattern" "$file"
  fi
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

#========================================
# HELP MESSAGE
#========================================
print_header() {
  echo -e "${BLUE}========================================================${NC}"
  echo -e "${BLUE}  ${PROJECT_NAME} Build System — Version: ${VERSION}${NC}"
  echo -e "${BLUE}========================================================${NC}"
}

help_msg() {
cat <<EOF
Usage:
  ./build.sh [command]

Commands:
  quick      Build onedir executable for the current system
  clean      Remove build artifacts
  zip      Zip the dist/${PROJECT_NAME}/ folder
  checksums    Generate SHA256 checksums for dist/${PROJECT_NAME}/
  help       Show this help message

Output:
  dist/${PROJECT_NAME}/     Onedir executable folder
  ${ZIP_NAME}         Zipped folder for distribution
EOF
}
#========================================
# Python + Dependencies
#========================================
install_python_dep() {
  if command_exists python3; then
    PYTHON=python3
  elif command_exists python; then
    PYTHON=python
  else
		echo -e "${RED}❌ Python not found.${NC}"
  fi

  if ! $PYTHON -m pip --version >/dev/null 2>&1; then
		echo -e "${YELLOW} Installing pip... ${NC}"

    curl -fsSL https://bootstrap.pypa.io/get-pip.py | $PYTHON -
  fi

	echo -e "${YELLOW} Installing project dependencies... ${NC}"


	$PYTHON -m pip install $(sed -e '1,/dependencies = \[/d' -e '/\]/,$d' pyproject.toml | tr -d '",')


	$PYTHON -m pip install pyinstaller


}

#========================================
# BUILD FUNCTIONS
#========================================
build_quick() {
	# 1. Override the global VERSION if $1 is provided
	if [ -n "${1:-}" ]; then
			VERSION="$1"
	fi

	echo -e "${YELLOW}⚙️ Building onedir executable for current system...${NC}"

	# 2. Inject Version into cli.py
	# This ensures --version works in the final binary
	sed_inplace "s/__version__ = .*/__version__ = \"$VERSION\"/" "awscli_addons/cli.py"

	# 3. Run PyInstaller (Once, with all flags)
	# Set variables for the BUILD process
	export PYTHONDONTWRITEBYTECODE=1
	export PYTHONOPTIMIZE=1
	
	pyinstaller --onefile --name "$PROJECT_NAME" \
    --exclude-module tkinter --exclude-module unittest --exclude-module pydoc \
    --strip --noupx --clean \
    "$SRC_DIR/cli.py"
	
	# IMPORTANT: Force macOS to trust the onefile extraction
	if [[ "$OSTYPE" == "darwin"* ]]; then
			echo "🔒 Ad-hoc signing for macOS speed..."
			codesign --force --deep --sign - "dist/$PROJECT_NAME"
			xattr -d com.apple.quarantine "dist/$PROJECT_NAME" 2>/dev/null || true
	fi

	echo -e "${GREEN}✔ Build complete! Output folder: ${DIST_DIR}/${PROJECT_NAME}${NC}"
}

zip_dist() {
  if [ ! -d "$DIST_DIR/$PROJECT_NAME" ]; then
    echo -e "${RED}❌ dist folder not found. Run build first.${NC}"
    exit 1
  fi
  echo -e "${YELLOW}📦 Zipping dist folder...${NC}"
  zip -r "$ZIP_NAME" "$DIST_DIR/$PROJECT_NAME"
  echo -e "${GREEN}✔ Zipped: $ZIP_NAME${NC}"
}

generate_checksums() {
  if [ ! -d "$DIST_DIR/$PROJECT_NAME" ]; then
    echo -e "${RED}❌ dist folder not found. Run build first.${NC}"
    exit 1
  fi
  echo -e "${YELLOW}🔐 Generating SHA256 checksums...${NC}"
  cd "$DIST_DIR/$PROJECT_NAME"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum ./* > checksums.txt
  else
    shasum -a 256 ./* > checksums.txt
  fi
  cd ../..
  echo -e "${GREEN}✔ Checksums saved to dist/${PROJECT_NAME}/checksums.txt${NC}"
}

clean() {
  echo -e "${YELLOW}🧹 Cleaning old builds...${NC}"
  rm -rf "$DIST_DIR" "$BUILD_DIR" "$ZIP_NAME" "${PROJECT_NAME}.spec" "__pycache__"
  echo -e "${GREEN}✔ Clean complete.${NC}"
}

#========================================
# MAIN LOGIC
#========================================
print_header

cmd="${1:-quick}"
case "$cmd" in
  quick)
    clean
		install_python_dep
    build_quick "${2:-}"
    ;;
  clean)
    clean
    ;;
  zip)
    zip_dist
    ;;
  checksums)
    generate_checksums
    ;;
  help|--help|-h)
    help_msg
    ;;
  *)
    echo -e "${RED}Unknown command: $cmd${NC}"
    help_msg
    exit 1
    ;;
esac
