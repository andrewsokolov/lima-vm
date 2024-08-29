INSTANCE_NAME = dev
SSH_KEY_NAME = id_ed25519
PROJECT_NAME = python-scylla-project
LIMA_INSTANCE = dev
export LIMA_INSTANCE

HOME_DIR := $(shell if [ -d "/Users" ]; then echo "/Users"; else echo "/home"; fi)

start:
	limactl rm $$LIMA_INSTANCE
	limactl start template://default --name $$LIMA_INSTANCE

restart:	
	limactl stop $$LIMA_INSTANCE || true
	limactl start $$LIMA_INSTANCE

init:
	lima sudo apt update
	lima sudo apt install -y $$(cat packages.txt)
	lima sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended" || true
	git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1 || true
	ln -s "$$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$$ZSH_CUSTOM/themes/spaceship.zsh-theme" || true

	lima sh -c "sed -i 's/^ZSH_THEME=\"[^\"]*\"/ZSH_THEME=\""spaceship"\"/' ~/.zshrc"

	curl -sSL https://install.python-poetry.org | python3 -

	lima sh -c "mkdir -p ~/.ssh"

	lima sh -c 'if [ -f "$(HOME_DIR)/$$USER/.ssh/id_rsa" ]; then \
		cp $(HOME_DIR)/$$USER/.ssh/id_rsa ~/.ssh/id_rsa; \
		cp $(HOME_DIR)/$$USER/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub; \
	else  \
		echo "$(HOME_DIR)/$$USER/.ssh/id_rsa not found"; \
	fi'

	lima sh -c 'if [ -f "$(HOME_DIR)/$$USER/.ssh/id_ed25519" ]; then \
		cp $(HOME_DIR)/$$USER/.ssh/id_ed25519 ~/.ssh/id_ed25519; \
		cp $(HOME_DIR)/$$USER/.ssh/id_ed25519.pub ~/.ssh/id_ed25519.pub; \
	else  \
		echo "$(HOME_DIR)/$$USER/.ssh/id_ed25519 not found"; \
	fi'

	lima sh -c 'if ! grep -q "source $$(pwd)/.devrc" ~/.zshrc; then \
        echo "source $$(pwd)/.devrc" >> ~/.zshrc; \
    fi'

repo:
	lima git config --global user.name "Andrew Sokolov"
	lima git config --global user.email "mr.andrewsokolov@gmail.com"
	lima sh -c "mkdir -p ~/repos"
	lima sh -c "git clone git@github.com:andrewsokolov/$(PROJECT_NAME).git ~/repos/$(PROJECT_NAME) || true"

shell:
	@@limactl copy spaceshiprc.zsh $$LIMA_INSTANCE:~/.spaceshiprc.zsh > /dev/null 2>&1
	@limactl shell --shell zsh $$LIMA_INSTANCE 
	
vscode:
	@echo 'add to vscode settings: "remote.SSH.configFile": "/home/deck/.lima/$$LIMA_INSTANCE/ssh.config"'