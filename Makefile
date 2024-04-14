INSTANCE_NAME=dev
SSH_KEY_NAME=id_ed25519
PROJECT_NAME=scylla-project
LIMA_INSTANCE=dev
LIMA_SHELL=/bin/zsh
export LIMA_INSTANCE
export LIMA_SHELL

HOME_DIR := $(shell if [ -d "/Users" ]; then echo "/Users"; else echo "/home"; fi)

start:
	limactl start template://archlinux --name dev

init:
	lima sudo pacman-key --init
	lima sudo pacman -S --noconfirm archlinux-keyring
	lima sudo pacman-key --populate archlinux
	lima sudo pacman -Syu --noconfirm
	lima sudo pacman -S --noconfirm git wget docker docker-compose zsh make nano which htop go
	lima sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended" || true

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

	lima sudo systemctl start docker.service
	lima sudo systemctl enable docker.service
	lima sh -c "sudo usermod -aG docker $$USER"
	lima sh -c "sudo chmod 666 /var/run/docker.sock"

	lima sh -c 'if ! grep -q "cd ~/repos/$(PROJECT_NAME)" ~/.zshrc; then \
        echo "cd ~/repos/$(PROJECT_NAME)" >> ~/.zshrc; \
    fi'

repo:
	lima git config --global user.name "Andrew Sokolov"
	lima git config --global user.email "mr.andrewsokolov@gmail.com"
	lima sh -c "mkdir -p ~/repos"
	lima sh -c "git clone git@github.com:andrewsokolov/$(PROJECT_NAME).git ~/repos/$(PROJECT_NAME) || true"

shell:
	@lima
	
vscode:
	@echo 'add to vscode settings: "remote.SSH.configFile": "$(HOME_DIR)/$(USER)/.lima/dev/ssh.config"'