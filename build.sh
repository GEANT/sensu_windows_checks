# pip install git-changelog
#
# create a new tag and run this script
#
ASSET_NAME=$(basename $(pwd))
ASSET_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1) | tr -d v)
git-changelog > CHANGELOG.md
tar czf "${ASSET_NAME}-${ASSET_VERSION}.tar.gz LICENSE README.md CHANGELOG.md bin/"

sha512sum ./*.tar.gz > "${ASSET_NAME}-${ASSET_VERSION}_sha512-checksums.txt"

