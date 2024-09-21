#!/bin/sh

lima sudo apt update
lima sudo apt install -y $(cat packages.txt)
lima sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended" || true
lima zsh -c 'source ~/.zshrc && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k' || true
lima zsh -c 'sed -i '\''s/^ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/'\'' $HOME/.zshrc'
lima zsh -c 'echo "install poetry"'
lima zsh -c 'curl -sSL https://install.python-poetry.org | python3 -'
lima zsh -c "mkdir -p ~/.ssh"

# lima sh -c 'if [ -f "$(HOME_DIR)/$USER/.ssh/id_rsa" ]; then \
#     cp $(HOME_DIR)/$USER/.ssh/id_rsa ~/.ssh/id_rsa; \
#     cp $(HOME_DIR)/$USER/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub; \
# else  \
#     echo "$(HOME_DIR)/$USER/.ssh/id_rsa not found"; \
# fi'

# lima sh -c 'if [ -f "$HOME_DIR/$USER/.ssh/id_ed25519" ]; then \
#     cp $HOME_DIR/$USER/.ssh/id_ed25519 ~/.ssh/id_ed25519; \
#     cp $HOME_DIR/$USER/.ssh/id_ed25519.pub ~/.ssh/id_ed25519.pub; \
# else  \
#     echo "$HOME_DIR/$USER/.ssh/id_ed25519 not found"; \
# fi'

lima sh -c 'if ! grep -q "source $(pwd)/.devrc.zsh" ~/.zshrc; then \
    echo "source $(pwd)/.devrc.zsh" >> ~/.zshrc; \
fi'