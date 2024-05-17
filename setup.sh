#!/bin/bash
#
#	_______
#	\_   _/
#	  |_|horbits 
#
#	My bash config


RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

command_exists() {
    command -v $1 >/dev/null 2>&1
}

# Check the current distribution
distribution () {
	local dtype="unknown"  # Default to unknown

	# Use /etc/os-release for modern distro identification
	if [ -r /etc/os-release ]; then
		source /etc/os-release
		case $ID in
			fedora|rhel|centos)
				dtype="redhat"
				;;
			sles|opensuse*)
				dtype="suse"
				;;
			ubuntu|debian)
				dtype="debian"
				;;
			gentoo)
				dtype="gentoo"
				;;
			arch)
				dtype="arch"
				;;
			slackware)
				dtype="slackware"
				;;
			*)
				# If ID is not recognized, keep dtype as unknown
				;;
		esac
	fi
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    if ! command_exists ${REQUIREMENTS}; then
        echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi

    ## Check Package manager.
    PACKAGEMANAGER='apt dnf pacman zypper'
    for pgm in ${PACKAGEMANAGER}; do
        if command_exists ${pgm}; then
            PACKAGER=${pgm}
            echo -e "Using ${pgm}"
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        echo -e "${RED}Can't find a supported package manager"
        exit 1
    fi

    ## Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
        echo -e "${RED}Can't write to ${GITPATH}${RC}"
        exit 1
    fi

    ## Check SuperUser group.
    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep ${sug}; then
            SUGROUP=${sug}
            echo -e "Super user group ${SUGROUP}"
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep ${SUGROUP} >/dev/null; then
        echo -e "${RED}You need to be a member of the sudo group to run me!"
        exit 1
    fi
}

# Automatically install the needed support files for this .bashrc file
install_bashrc_support() {
	local dtype
	dtype=$(distribution)

	case $dtype in
 		"arch")
			sudo paru multitail tree zoxide trash-cli fzf bash-completion fastfetch
			;;
		"debian")
			sudo apt-get install multitail tree zoxide trash-cli fzf bash-completion
			# Fetch the latest fastfetch release URL for linux-amd64 deb file
			FASTFETCH_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*linux-amd64.deb" | cut -d '"' -f 4)
			
			# Download the latest fastfetch deb file
			curl -sL $FASTFETCH_URL -o /tmp/fastfetch_latest_amd64.deb
			
			# Install the downloaded deb file using apt-get
			sudo apt-get install /tmp/fastfetch_latest_amd64.deb
			;;
   		"redhat")
			sudo dnf install multitail tree zoxide trash-cli fzf bash-completion fastfetch
			;;
		"suse")
			sudo zypper install multitail tree zoxide trash-cli fzf bash-completion fastfetch
			;;
		*)
			echo "Unknown distribution"
			;;
	esac
}

install_dependencies() {
    ## Check for dependencies.
    DEPENDENCIES='bash bash-completion tar neovim bat tree multitail fastfetch'
    echo -e "${YELLOW}Installing dependencies...${RC}"
    if [[ $PACKAGER == "pacman" ]]; then
        if ! command_exists yay && ! command_exists paru; then
            echo "Installing yay as AUR helper..."
            sudo ${PACKAGER} --noconfirm -S base-devel
            cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R ${USER}:${USER} ./yay-git
            cd yay-git && makepkg --noconfirm -si
        else
            echo "Aur helper already installed"
        fi
        if command_exists yay; then
            AUR_HELPER="yay"
        elif command_exists paru; then
            AUR_HELPER="paru"
        else
            echo "No AUR helper found. Please install yay or paru."
            exit 1
        fi
        ${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
    else
        sudo ${PACKAGER} install -yq ${DEPENDENCIES}
    fi
}

install_additional_dependencies() {
   sudo apt update
   sudo apt install -y trash-cli bat meld jpico
}

linkConfig() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${USER_HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]]; then
        echo -e "${YELLOW}Moving old bash config file to ${USER_HOME}/.bashrc.bak${RC}"
        if ! mv ${OLD_BASHRC} ${USER_HOME}/.bashrc.bak; then
            echo -e "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new bash config file...${RC}"
    ## Make symbolic link.
    ln -svf ${GITPATH}/.bashrc ${USER_HOME}/.bashrc
}

checkEnv
install_dependencies
## install_additional_dependencies

if linkConfig; then
    echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi
