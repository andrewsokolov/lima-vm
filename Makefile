INSTANCE_NAME = dev
SSH_KEY_NAME = id_ed25519
PROJECT_NAME = scylla-project
LIMA_INSTANCE = dev
export LIMA_INSTANCE

start:
	limactl rm $$LIMA_INSTANCE
	limactl start template://archlinux --name $$LIMA_INSTANCE

init:
	lima sudo pacman-key --init
	lima sudo pacman-key --populate archlinux
	lima sudo pacman -Sy --noconfirm archlinux-keyring
	lima sudo pacman -Syu
	lima sudo pacman -S --noconfirm git wget docker zsh make nano bat
	lima sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
	lima sh -c "sudo chsh -s $$(which zsh) $$USER"
	lima sh -c "mkdir -p ~/.ssh"
	lima cp /home/deck/.ssh/id_rsa /home/deck.linux/.ssh/id_rsa
	lima cp /home/deck/.ssh/id_rsa.pub /home/deck.linux/.ssh/id_rsa.pub
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
	@limactl shell --shell zsh $$LIMA_INSTANCE 
	
vscode:
	@echo 'add to vscode settings: "remote.SSH.configFile": "/home/deck/.lima/$$LIMA_INSTANCE/ssh.config"'