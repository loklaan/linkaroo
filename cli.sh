#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

prog_name=$(basename $0)

#/ Usage:
#/
#/   linkaroo pack
#/   linkaroo link <name> <tar-path>
#/
#/ Description:
#/
#/   Set of commands to "link" packages with zero side-effects.
#/
#/ Examples:
#/
#/   # First step: pack your package!
#/
#/   $ cd my-pkg
#/   $ linkaroo pack
#/     Packing "my-pkg"... Packed!
#/
#/     Run the following in your other package or app:
#/
#/       linkaroo link "my-pkg" "/tmp/linkaroo/my-pkg-1.0.0.tgz"
#/       ^ Copied to clipboard. :)
#/
#/     ...Bai!
#/
#/   # Second step: unpack your packed package! (:
#/
#/   $ cd my-app
#/   $ linkaroo link "my-pkg" "/tmp/linkaroo/my-pkg-0.1.0.tgz"
#/     Linking "my-pkg"
#/
#/       my-pkg-0.1.0.tgz  ⟹   node_modules/my-pkg
#/
#/     ...Bai!
#/
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo -e "[INFO]  $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo -e "[WARN]  $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo -e "[ERROR] $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo -e "[FATAL] $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

cleanup() {
  echo -e "\n...Bai!"
}

function clipboard_copy () {
    local os=`uname`
    case $OSTYPE in
        # Mac OS X
        darwin*)
            pbcopy
            ;;
        # Windows Cygwin
        cygwin*)
            cat > /dev/clipboard
            ;;
        # Linux
        linux*)
            if hash xclip 2>/dev/null; then
                xclip -in -selection clipboard
            fi
            if hash xsel 2>/dev/null; then
                xsel --clipboard --input
            fi
            ;;
        *)
          print "clipboard: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
          ;;
    esac
}

function sub_pack () {
  local package_name="$(node -pe "require('./package.json').name")" && \
  printf "Packing \"$package_name\"... " && \
  local package_tar=$(npm pack --silent) && \
  local tmp_package_path="/tmp/linkaroo/$package_tar" && \
  mkdir -p /tmp/linkaroo && \
  mv "./$package_tar" "$tmp_package_path"
  echo "Packed!"
  local link_cmd="linkaroo link \"$package_name\" \"$tmp_package_path\""
  echo -e "\nRun the following in your other package or app:\n\n  $link_cmd" && \
  printf "$link_cmd" | clipboard_copy && \
  echo "  ^ Copied to clipboard. :)"
}

function sub_link () {
  local package_name="${1:?required}"
  local src_tgz="${2:?required}"
  local package_dir="node_modules/$package_name"
  local under_package_dir="$package_dir/package"

  echo "Linking \"$package_name\""
  echo ""
  echo "  $(basename "$src_tgz")  ⟹   $package_dir"
  rm -rf "$package_dir" && \
  mkdir "$package_dir" && \
  tar --strip=1 -C "$package_dir" -xzf "$src_tgz"
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  trap cleanup EXIT

  subcommand=$1
    case ${subcommand} in
        "" | "-h" | "--help")
            sub_help
            ;;
        *)
            shift
            sub_${subcommand} $@
            if [[ $? = 127 ]]; then
                echo "Error: '$subcommand' is not a known subcommand." >&2
                echo "       Run '$prog_name --help' for a list of known subcommands." >&2
                exit 1
            fi
            ;;
    esac
fi
