#!/bin/sh

lima sudo apt update
lima sudo apt install -y $(cat packages.txt)
lima sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended" || true
lima zsh -c 'source ~/.zshrc && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k' || true
lima zsh -c 'sed -i '\''s/^ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/'\'' $HOME/.zshrc'
lima zsh -c 'echo "install poetry"'
lima zsh -c 'curl -sSL https://install.python-poetry.org | python3 -'
lima zsh -c "mkdir -p ~/.ssh"

lima sh -c 'ssh-keygen -t rsa -b 4096 -C "mr.andrewsokolov@gmail.com" -f ~/.ssh/id_rsa -N ""'

lima sh -c 'if ! grep -q "source $(pwd)/.devrc.zsh" ~/.zshrc; then \
    echo "source $(pwd)/.devrc.zsh" >> ~/.zshrc; \
fi'