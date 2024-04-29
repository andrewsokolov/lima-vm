INSTANCE_NAME=dev
SSH_KEY_NAME=id_ed25519
PROJECT_NAME=scylla-project
LIMA_INSTANCE=dev
export LIMA_INSTANCE

HOME_DIR := $(shell if [ -d "/Users" ]; then echo "/Users"; else echo "/home"; fi)

create:
	mkdir -p .tmp
	curl https://raw.githubusercontent.com/lima-vm/lima/master/examples/fedora.yaml -o .tmp/lima-vm-fedora.yaml
	docker run --rm -v ./:/workdir mikefarah/yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' /workdir/.tmp/lima-vm-fedora.yaml /workdir/vm-config.yaml | tee ./.tmp/lima-vm-fedora-modified.yaml
	limactl create --name=dev ./.tmp/lima-vm-fedora-modified.yaml

init:
	lima sudo dnf update -y
	lima sudo dnf -y install dnf-plugins-core
	lima sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
	lima sudo dnf install -y docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin --allowerasing
	lima sudo dnf install -y git wget zsh make nano which htop go
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
	limactl start dev
	@LIMA_SHELL=/bin/zsh lima
	
vscode:
	@echo 'add to vscode settings: "remote.SSH.configFile": "$(HOME_DIR)/$(USER)/.lima/dev/ssh.config"'

tunnel:
	lima docker run cloudflare/cloudflared:latest tunnel --no-autoupdate login
	lima docker run cloudflare/cloudflared:latest tunnel --no-autoupdate create andrewsokolov

