#!/bin/bash

mkdir ~/upgradelogs/
cp /etc/apt/sources.list  sources.back
echo ' Privacy: This bash script upgrade your server. Remember, if you have important data on the server, you can make a backup first. otherwise I will try to create a backup for your configuration and you can restore it anytime. Do you accept this? '
    select yn in "Yes" "No" ;do
       case $yn in
            Yes) break;;
            No) exit;;
	     *) echo "I cant understand, it's a simple question...enter 1 for Yes or 2 for No " >&2
       esac
        done


echo "Thanks for using this script....."
sleep 2s
reset

rotateCursor() {
s="-,\\,|,/"
    for i in `seq 1 $1`; do
        for i in ${s//,/ }; do
            echo -n $i
            sleep 0.1
            echo -ne '\b'
        done
    done
}

# Single loop, kann man ohne Zahl eingeben
rotateCursor

# mehrere loops
rotateCursor 10


check_os () {
    echo "Checking your OS...."
lsb_release -a |& tee ~/upgradelogs/checkos-logs.txt
}

upgrade () {
apt  update -y && apt upgrade -y |& tee ~/upgradelogs/firstupdatelogs.txt

ufw allow 1022/tcp

ufw reload

ufw status

apt install update-manager-core -y |& tee ~/upgradelogs/mngcorelogs.txt

cp /etc/update-manager/release-upgrades release-upgrades.back
cat > /etc/update-manager/release-upgrades << 'EOL'              
# Default behavior for the release upgrader.

[DEFAULT]
# Default prompting and upgrade behavior, valid options:
#
#  never  - Never check for, or allow upgrading to, a new release.
#  normal - Check to see if a new release is available.  If more than one new
#           release is found, the release upgrader will attempt to upgrade to
#           the supported release that immediately succeeds the
#           currently-running release.
#  lts    - Check to see if a new LTS release is available.  The upgrader
#           will attempt to upgrade to the first LTS release available after
#           the currently-running one.  Note that if this option is used and
#           the currently-running release is not itself an LTS release the
#           upgrader will assume prompt was meant to be normal.
Prompt=normal
EOL


sudo apt update -y
sudo do-release-upgrade -d
sudo do-release-upgrade

}

after_reboot () {

ufw delete allow 1022/tcp
sudo apt autoremove --purge
sudo update-manager -c
sudo reboot
}

ubuntu20 () {
rm /etc/apt/sources.list
cat > /etc/apt/sources.list << 'EOL'
deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse

deb http://archive.canonical.com/ubuntu focal partner
deb-src http://archive.canonical.com/ubuntu focal partner

EOL
apt update -y
}

ubuntu21 () {
rm /etc/apt/sources.list
cat > /etc/apt/sources.list << 'EOL'
deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse

deb http://archive.canonical.com/ubuntu focal partner
deb-src http://archive.canonical.com/ubuntu focal partner

EOL
apt update -y
}

ubuntu22 () {
rm /etc/apt/sources.list
cat > /etc/apt/sources.list << 'EOL'
deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse

deb http://archive.canonical.com/ubuntu/ jammy partner
# deb-src http://archive.canonical.com/ubuntu/ jammy partner

EOL
apt update -y
}

error_apt () {

options=("repair my apt ubuntu20" "repair my apt ubuntu21" "repair my apt ubuntu22" )

    echo "Choose an option to repair your broken apt:"
    select opt in "${options[@]}"; do
        case $REPLY in
            1) ubuntu20; break ;;
            2) ubuntu21; break ;;
            3) ubuntu22; break ;;
            *) echo "i cant understand your entrie, choose 1 or 2..etc" >&2
        esac
    done

}

recovery () {
rm /etc/apt/sources.list
cp /etc/apt/sources.back  source.list
sudo apt update -y
sudo apt autoremove --purge -y

}

while true; do
    options=("Checking your OS" "upgrade the server" "did you get error due to apt" "if your reboot is done" "recovery, undo system change" )

    echo "Choose an option:"
    select opt in "${options[@]}"; do
        case $REPLY in
            1) check_os; break ;;
            2) upgrade; break ;;
            3) error_apt; break ;;
            4) after_reboot; break ;;
	        5) recovery; break ;;
            *) echo "i cant understand your entrie, choose 1 or 2..etc" >&2
        esac
    done

    echo "Have you completed your task?"
    select opt in "break the installation" "Yes, go back to installation"; do
        case $REPLY in
            1) break 2 ;;
            2) break ;;
            *) echo "I cant understand, it's a simple question...enter 1 or 2 and so on" >&2
        esac
    done
done
