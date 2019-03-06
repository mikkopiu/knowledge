#!/bin/sh -e

# Original source: https://github.com/dainnilsson/scripts/blob/master/base-install/gpg.sh 
# Modified by: Mikko Piuhola <me@mikkopiuhola.fi>

#Install needed stuff:
sudo apt-get install gnupg2 pcscd scdaemon

#Create .gnupg dir
gpg2 --list-keys

#Use SHA2 instead of SHA1
echo "personal-digest-preferences SHA256" >> ~/.gnupg/gpg.conf
echo "cert-digest-algo SHA256" >> ~/.gnupg/gpg.conf
echo "default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed" >> ~/.gnupg/gpg.conf

#Set a default keyserver
echo "keyserver hkp://keys.gnupg.net" >> ~/.gnupg/gpg.conf

#Configure gpg-agent:
echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf

#Restart agent
gpg-connect-agent killagent /bye
gpg-connect-agent /bye

#Use gpg2 instead of gpg.
echo "alias gpg=gpg2" >> ~/.bash_aliases

