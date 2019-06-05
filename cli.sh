#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

prog_name=$(basename $0)

c_reset="\e[0m"
c_bold="\e[1m"
c_dim="\e[2m"
c_uline="\e[4m"
c_invert="\e[7m"
c_red="\e[31m"
c_green="\e[32m"
c_blue="\e[34m"

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
#/       linkaroo link "my-pkg@1.0.0"
#/       ^ Copied to clipboard. :)
#/
#/     ...Bai!
#/
#/   # Second step: unpack your packed package! (:
#/
#/   $ cd my-app
#/   $ linkaroo link "my-pkg@1.0.0"
#/     Linking "my-pkg"
#/
#/       Linkroo's Cache  ⟹  node_modules/my-pkg
#/
#/     ...Bai!
#/
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="$(node -pe "require('os').tmpdir()")/$(basename "$0").log"
readonly LINKAROO_TMP_PATH="$(node -pe "require('os').tmpdir()")/linkaroo"
info()    { echo -e "[INFO]  $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo -e "[WARN]  $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo -e "[ERROR] $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo -e "[FATAL] $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

cleanup() {
    case $? in
        0*)
          # successful exit
            echo -e "\n...Bai! ✨"
            ;;
        *)
          # do nothing on errors
          ;;
    esac
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

function package_ref_to_npm_tar () {
  #     @foo/pkg@1.0.0-alpha.1  ->  foo-pkg-1.0.0-alpha.1.tgz
  #          pkg@1.0.0-alpha.1  ->  pkg-1.0.0-alpha.1.tgz
  echo "$(echo $1 | sed 's/^@//' | sed 's/[@\/]/-/g').tgz"
}

function package_ref_to_package_name () {
  #     @foo/pkg@1.0.0-alpha.1  ->  @foo/pkg
  #          pkg@1.0.0-alpha.1  ->  pkg
  echo $1 | sed -e 's/\(.*\)@[0-9]\{1,99\}\..*/\1/'
}

function sub_pack () {
  local package_name="$(node -pe "require('./package.json').name")" && \
  local package_ver="$(node -pe "require('./package.json').version")" && \
  local package_ref="$package_name@$package_ver" && \
  printf "\nLinkaroo is packing \"${c_uline}$package_ref${c_reset}\"... " && \
  local npm_tar="$(npm pack --silent)" && \
  local npm_tar_in_tmp_path="$LINKAROO_TMP_PATH/$npm_tar" && \
  mkdir -p ${LINKAROO_TMP_PATH} && \
  mv "./$npm_tar" "$npm_tar_in_tmp_path" && \
  printf "${c_green}Packed${c_reset}!\n" && \
  local link_cmd="linkaroo link \"$package_ref\"" && \
  printf "\n ${c_dim}\$${c_reset} ${c_bold}$link_cmd${c_reset}\n" && \
  printf "$link_cmd" | clipboard_copy && \
  printf "   ${c_dim}^ Copied to clipboard 👍${c_reset}\n"
  printf "     ${c_dim}Run in your other package or app.${c_reset}\n"
}

function sub_link () {
  local package_ref="${1:?required}" && \
  local package_name="$(package_ref_to_package_name ${package_ref})" && \
  local npm_tar="$(package_ref_to_npm_tar ${package_ref})" && \
  local package_dir="node_modules/$package_name" && \
  local npm_tar_in_tmp_path="$LINKAROO_TMP_PATH/$npm_tar"
  printf "\nLinking \"${c_uline}$package_ref${c_reset}\"... " && \

  if [[ -f "$npm_tar_in_tmp_path" ]]; then
    printf "${c_green}Linked$c_reset!\n" && \
    rm -rf "$package_dir" && \
    mkdir "$package_dir" && \
    tar --strip=1 -C "$package_dir" -xzf "$npm_tar_in_tmp_path"
  else
    printf "${c_red}Error${c_reset}!\n" && \
    printf "\n${c_red}The package \"${c_bold}$package_ref${c_reset}${c_red}\" has not been packed.${c_reset}\n" && \
    printf "\n${c_dim}Are you sure ${c_bold}linkaroo pack${c_reset}${c_dim} was run from $package_name's directory?${c_reset}\n" && \
    exit 1
  fi

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
