#!/bin/sh -e

echo 'Setting up Yubico repo and installing required PAM libs...'
sudo add-apt-repository ppa:yubico/stable && sudo apt-get update
sudo apt-get install libpam-u2f

echo 'Associating Yubikey with your account...'
echo 'Touch the device when it blinks'
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys

echo 'Configuring login, via gdm-password...'
sudo sed -i '/@include common-auth/a auth\trequired\tpam_u2f.so' /etc/pam.d/gdm-password

echo 'Done!'

