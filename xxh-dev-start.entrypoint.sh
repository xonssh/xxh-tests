#!/bin/bash

for user_dir in /home/*; do
  username=`basename $user_dir`
  echo Prepare $user_dir

  cd $user_dir
  cp /home/root/.bash_history .
  chown $username:$username .bash_history

  cp /xxh/xxh-dev/keys/id_rsa .
  chown $username:$username id_rsa
  chmod 0600 id_rsa

  if [[ $username == *"root"* ]]; then
    echo 'export PATH=/xxh/xxh:$PATH' >> .bashrc
  elif [[ $username == *"xonsh"* ]]; then
    echo '$PATH=["/xxh/xxh"]+$PATH' >> .xonshrc
  elif [[ $username == *"zsh"* ]]; then
    echo 'export PATH=/xxh/xxh:$PATH' >> .zshrc
  elif [[ $username == *"fish"* ]]; then
    mkdir -p .config/fish/
    echo 'set PATH /xxh/xxh $PATH' >> .config/fish/config.fish
  fi

done

echo 'DONE'
tail -f /dev/null
