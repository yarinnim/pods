#! /usr/bin/bash

install_terminator() {
  sudo apt install terminator
  mkdir -p ~/.config/terminator
  cp ~/.config/terminator/config ~/.config/terminator/config.bk || true
  cp ./terminator.conf ~/.config/terminator/config
}

install_fnm() {
  sudo curl -fsSL https://fnm.vercel.app/install | bash 
  source ~/.bashrc
  fnm use 24 # Install Node v24
}

install_vim() {
  # Install VIM
  sudo apt install vim universal-ctags ripgrep
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  mkdir -p ~/.vim/colors
  cp vim/gruvbox.vim ~/.vim/colors/.
  sudo apt-get install vim-gtk3 # Enable clipboard
  cp ./vim/vimrc ~/.vimrc
}

install_lazygit() {
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
}

touch_bash() {
  mkdir -p ~/.local/share/fonts
  cp ./nerd-font/* ~/.local/share/fonts/.
  cp ~/.bashrc ~/bashrc.bk
  cp ./bashrc/bashrc.sh ~/.
  cp ./bashrc/bashrc ~/.bashrc
  source  ~/.bashrc
}

install() {
	# Update
	sudo apt update && sudo apt upgrade
	sudo apt install curl
	touch_bash
	install_fnm
	install_lazygit
	install_vim
	install_terminator
}

install
