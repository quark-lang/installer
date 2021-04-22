#!/bin/sh
set -e 

# Checking for git command
if ! command -v git &> /dev/null; then
  echo "Git is required to install latest Quark version."
  exit 1
fi

if ! command -v deno &> /dev/null; then
  echo "Deno is required to install latest Quark version."
  exit 1
fi

quark_folder="${HOME}"
exe="${quark_folder}/quark"

cd "$quark_folder"

if [ -d "quark" ]; then
  rm -rf quark
fi

echo "🔽 Cloning Quark core into $exe..."
git clone https://github.com/quark-lang/quark -q
cd quark
echo "🔽 Cloning CLI..."
git clone https://github.com/quark-lang/cli -q
echo "🔽 Cloning STD..."
git clone https://github.com/quark-lang/std -q

deno install --no-check --unstable -A -f -n quark src/main.ts > /dev/null 2>&1
echo "✅ Successfully installed quark to $exe"

if command -v quark &> /dev/null; then
  echo "✴️  Run 'quark --help' to get started"
else

  case $SHELL in
    /bin/zsh) shell_profile=".zshrc" ;;
    *) shell_profile=".bash_profile" ;;
  esac

  echo "Exports the following variable to $shell_profile (or similar)"
  echo "  export QUARK=\"$exe\""
  echo "✴️  Run 'quark --help' to get started"
fi
exit 0