#!/usr/bin/env bash
set -euo pipefail

ERROR=$'\033[0;31mError\033[0m'
DONE=$'\033[0;32mdone\033[0m'

if ! command -v wget &> /dev/null
then
	echo "$ERROR: Wget is required to install the latest Quark release."
	exit 1
fi

echo -n "* Searching a release..."

TAG=$(curl --silent "https://api.github.com/repos/quark-lang/quark/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

echo " found '${TAG}'"

DL_LINK="https://github.com/quark-lang/quark/releases/download/${TAG}/"

KERNEL=$(uname -a | awk '{print $1}')
FILE=quark-ubuntu-latest.zip

if [[ $KERNEL == "Darwin" ]]
then
	FILE="quark-macos-latest.zip"
elif [[ $KERNEL != "Linux" ]]
then
	echo "$ERROR: Your kernel (${KERNEL}) is currently not supported. Please open an issue at <https://github.com/quark-lang/quark/issues/new> to reclaim it."
	exit 1
fi

INSTALL_FOLDER="${HOME}/.quark"

if [[ "$#" -geq 1 ]]
then
	INSTALL_FOLDER = "$1"
fi

if [[ -d $INSTALL_FOLDER ]]
then
	rm -fr $INSTALL_FOLDER
fi

mkdir -p $INSTALL_FOLDER
cd $INSTALL_FOLDER

echo -n "* Downloading the latest Quark release archive... "
wget -q ${DL_LINK}/${FILE}
echo "$DONE"

echo -n "* Deflating archive..."
unzip -qq ${FILE}
echo "$DONE"

echo -n "* Cleaning ${INSTALL_FOLDER} directory..."
rm -fr ${FILE}
echo "$DONE"

case $SHELL in
	"/bin/bash"|"/usr/bin/bash")
		BASHRC="${HOME}/.bashrc"
		echo -n "* Configuring ${BASHRC}..."
		echo "PATH=${INSTALL_FOLDER}:\$PATH" >> $BASHRC
		echo "export QUARK=\"${INSTALL_FOLDER}\"" >> $BASHRC
		echo "$DONE"
		;;
	"/bin/zsh"|"/usr/bin/zsh")
		ZSHRC="${HOME}/.zshrc"
		echo -n "* Configuring ${ZSHRC}..."
		echo "PATH=${INSTALL_FOLDER}:\$PATH" >> $ZSHRC
		echo "export QUARK=\"${INSTALL_FOLDER}\"" >> $ZSHRC
		echo "$DONE"
		;;
	"/bin/fish"|"/usr/bin/fish")
		CONFIG_FISH="${HOME}/.config/fish/config.fish"
		echo -n "* Configuring ${CONFIG_FISH}..."
		echo "set PATH ${INSTALL_FOLDER} \$PATH" >> $CONFIG_FISH
		echo "export QUARK=\"${INSTALL_FOLDER}\"" >> $CONFIG_FISH
		echo "$DONE"
		;;
	*)
		echo "Your shell cannot be automatically configured."
		echo "Please add \"${INSTALL_FOLDER}\" to your \$PATH"
		echo "And set a \`QUARK\` environment variable pointing to \"${INSTALL_FOLDER}\"."
		;;
esac

echo 
