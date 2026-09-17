#!/usr/bin/env bash
# Проверка зависимостей для сборки llama.cpp WebUI
# Поддерживает: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch, Alpine
set -e

MISSING=()

# Определяем дистрибутив
DISTRO="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
    ubuntu|debian|linuxmint|pop) DISTRO="debian" ;;
    rhel|centos|fedora|rocky|almalinux) DISTRO="rhel" ;;
    arch|manjaro|endeavouros) DISTRO="arch" ;;
    alpine) DISTRO="alpine" ;;
    *) DISTRO="${ID:-unknown}" ;;
  esac
fi

install_hint() {
  local pkg_deb="$1"
  local pkg_rpm="$2"
  local pkg_arch="$3"
  local pkg_apk="$4"

  case "$DISTRO" in
    debian) echo "sudo apt install $pkg_deb" ;;
    rhel)   echo "sudo dnf install $pkg_rpm" ;;
    arch)   echo "sudo pacman -S $pkg_arch" ;;
    alpine) echo "sudo apk add $pkg_apk" ;;
    *)      echo "установи: $pkg_deb / $pkg_rpm" ;;
  esac
}

check() {
  local cmd="$1"
  local pkg_deb="$2"
  local pkg_rpm="$3"
  local pkg_arch="$4"
  local pkg_apk="$5"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    MISSING+=("$cmd  →  $(install_hint "$pkg_deb" "$pkg_rpm" "$pkg_arch" "$pkg_apk")")
  fi
}

echo "=== Проверка зависимостей ==="
echo "Дистрибутив: $DISTRO"
echo ""

# bash (явно)
if ! command -v bash >/dev/null 2>&1; then
  echo "❌ bash не найден!"
  echo "   Установи:"
  case "$DISTRO" in
    alpine) echo "   sudo apk add bash" ;;
    *)      echo "   sudo apt install bash  # или dnf/pacman" ;;
  esac
  exit 1
fi

# Версия bash >= 4.0
BASH_VER=$(bash --version | head -1 | grep -oP '\d+\.\d+' | head -1)
BASH_MAJOR=$(echo "$BASH_VER" | cut -d. -f1)
if [ "$BASH_MAJOR" -lt 4 ]; then
  echo "❌ bash $BASH_VER < 4.0 (нужен для массивов и mapfile)"
  echo "   Обнови bash"
  exit 1
fi

check node    nodejs    nodejs    nodejs    nodejs
check npm     npm       npm       npm       npm
check cmake   cmake     cmake     cmake     cmake
check python3 python3   python3   python    python3
check git     git       git       git       git
check make    make      make      make      make

# Node.js >= 18
if command -v node >/dev/null 2>&1; then
  NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
  if [ "$NODE_VER" -lt 18 ]; then
    echo ""
    echo "⚠ Node.js версия $NODE_VER < 18"
    case "$DISTRO" in
      rhel)   echo "   RHEL/CentOS: sudo dnf module install nodejs:20" ;;
      debian) echo "   Ubuntu: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs" ;;
      arch)   echo "   Arch: sudo pacman -S nodejs npm" ;;
      alpine) echo "   Alpine: sudo apk add nodejs npm" ;;
    esac
    MISSING+=("Node.js >= 18 (у тебя $NODE_VER)")
  fi
fi

if ! command -v nproc >/dev/null 2>&1; then
  echo "⚠ nproc не найден (будет -j4)"
fi

if [ ${#MISSING[@]} -gt 0 ]; then
  echo ""
  echo "❌ Не найдены зависимости:"
  for m in "${MISSING[@]}"; do
    echo "   - $m"
  done
  echo ""
  echo "Установка всего сразу:"
  echo "  Ubuntu/Debian:  sudo apt install -y build-essential cmake git python3 nodejs npm bash"
  echo "  RHEL/CentOS:    sudo dnf install -y gcc-c++ make cmake git python3 nodejs npm bash"
  echo "  RHEL 8+ Node:   sudo dnf module install nodejs:20"
  echo "  Fedora:         sudo dnf install -y gcc-c++ make cmake git python3 nodejs npm bash"
  echo "  Arch:           sudo pacman -S base-devel cmake git python nodejs npm bash"
  echo "  Alpine:         sudo apk add bash build-base cmake git python3 nodejs npm"
  exit 1
fi

echo ""
echo "✅ Все зависимости на месте"
echo ""
echo "  bash:    $BASH_VER (OK)"
echo "  node:    $(node -v)"
echo "  npm:     $(npm -v)"
echo "  cmake:   $(cmake --version | head -1)"
echo "  python3: $(python3 --version)"
echo "  git:     $(git --version)"
echo "  make:    $(make --version | head -1)"
echo "  nproc:   $(nproc 2>/dev/null || echo '4 (fallback)')"
