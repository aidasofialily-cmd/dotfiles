#!/usr/bin/env bash
#
# install.sh — simple cross-distro installer for project dependencies
#
# Usage:
#   ./install.sh               # interactive (asks for confirmation)
#   ./install.sh --yes         # non-interactive, assume yes
#   ./install.sh --dry-run     # show actions but don't run package manager
#   PACKAGES="git curl jq" ./install.sh
#   echo -e "git\ncurl\njq" > packages.txt && ./install.sh
#
set -euo pipefail

PROG_NAME="$(basename "$0")"
DRY_RUN=0
ASSUME_YES=0

print_help() {
  cat <<EOF
${PROG_NAME} — install project dependencies.

Options:
  --help        Show this help and exit
  --dry-run     Print commands that would be run, do not execute them
  --yes         Run non-interactively and answer "yes" to prompts

Package sources:
  - If the PACKAGES environment variable is set, packages from it are installed.
    Example: PACKAGES="git curl jq"
  - Else if packages.txt exists in working directory, it will be read (one package per line).
  - Otherwise, a small sensible default set will be used (git, curl).

Supported platforms:
  - Debian/Ubuntu (apt)
  - Fedora/RHEL (dnf/yum)
  - Arch (pacman)
  - macOS (brew)

EOF
}

run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY-RUN] $*"
  else
    echo "+ $*"
    eval "$@"
  fi
}

detect_pkg_manager() {
  if [ "$(uname -s)" = "Darwin" ]; then
    PKG_MGR="brew"
    return
  fi

  if command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
  elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
  elif command -v yum >/dev/null 2>&1; then
    PKG_MGR="yum"
  elif command -v pacman >/dev/null 2>&1; then
    PKG_MGR="pacman"
  else
    PKG_MGR="unknown"
  fi
}

ensure_sudo() {
  # On macOS, brew runs as user. On Linux, use sudo if not root.
  if [ "$(id -u)" -ne 0 ] && [ "$PKG_MGR" != "brew" ]; then
    SUDO="sudo"
  else
    SUDO=""
  fi
}

install_packages() {
  local pkgs=("$@")
  if [ "${#pkgs[@]}" -eq 0 ]; then
    echo "No packages to install."
    return
  fi

  case "$PKG_MGR" in
    apt)
      if [ "$ASSUME_YES" -eq 1 ]; then
        run_cmd "${SUDO} apt-get update -y"
        run_cmd "${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y ${pkgs[*]}"
      else
        run_cmd "${SUDO} apt-get update"
        run_cmd "${SUDO} apt-get install ${pkgs[*]}"
      fi
      ;;
    dnf)
      if [ "$ASSUME_YES" -eq 1 ]; then
        run_cmd "${SUDO} dnf install -y ${pkgs[*]}"
      else
        run_cmd "${SUDO} dnf install ${pkgs[*]}"
      fi
      ;;
    yum)
      if [ "$ASSUME_YES" -eq 1 ]; then
        run_cmd "${SUDO} yum install -y ${pkgs[*]}"
      else
        run_cmd "${SUDO} yum install ${pkgs[*]}"
      fi
      ;;
    pacman)
      if [ "$ASSUME_YES" -eq 1 ]; then
        run_cmd "${SUDO} pacman -Sy --noconfirm ${pkgs[*]}"
      else
        run_cmd "${SUDO} pacman -Sy ${pkgs[*]}"
      fi
      ;;
    brew)
      # Homebrew usually installs to user; no sudo
      for p in "${pkgs[@]}"; do
        if [ "$ASSUME_YES" -eq 1 ]; then
          run_cmd "brew install ${p}"
        else
          run_cmd "brew install ${p}"
        fi
      done
      ;;
    *)
      echo "Unsupported package manager: ${PKG_MGR}"
      return 1
      ;;
  esac
}

main() {
  # Parse args
  while [ $# -gt 0 ]; do
    case "$1" in
      --help) print_help; exit 0 ;;
      --dry-run) DRY_RUN=1; shift ;;
      --yes|--assume-yes) ASSUME_YES=1; shift ;;
      *) echo "Unknown option: $1"; print_help; exit 2 ;;
    esac
  done

  detect_pkg_manager
  if [ "$PKG_MGR" = "unknown" ]; then
    echo "Could not detect a supported package manager on this system."
    exit 1
  fi

  ensure_sudo

  # Determine packages
  PKG_LIST=()
  if [ -n "${PACKAGES-}" ]; then
    # split PACKAGES on whitespace
    read -r -a PKG_LIST <<<"$PACKAGES"
  elif [ -f "packages.txt" ]; then
    while IFS= read -r line; do
      line="$(echo "$line" | tr -d '\r')"
      [ -z "$line" ] && continue
      [[ "$line" =~ ^# ]] && continue
      PKG_LIST+=("$line")
    done < packages.txt
  else
    PKG_LIST=(git curl)
  fi

  echo "Detected package manager: $PKG_MGR"
  echo "Packages to install: ${PKG_LIST[*]:-<none>}"
  if
