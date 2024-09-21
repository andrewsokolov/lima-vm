#!/bin/sh

lima zsh -c 'source ~/.zshrc && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k' || true
lima zsh -c 'sed -i '\''s/^ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/'\'' $HOME/.zshrc'