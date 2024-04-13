INSTANCE_NAME = dev
SSH_KEY_NAME = id_ed25519
PROJECT_NAME = scylla-project

start:
	limactl start template://archlinux --name dev

init:
	LIMA_INSTANCE=dev lima sudo pacman-key --init
	LIMA_INSTANCE=dev lima sudo pacman-key --populate archlinux
	LIMA_INSTANCE=dev lima sudo pacman -Syu
	LIMA_INSTANCE=dev lima sudo pacman -S --noconfirm git wget docker zsh make nano
	LIMA_INSTANCE=dev lima sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
	LIMA_INSTANCE=dev lima sh -c "sudo chsh -s $$(which zsh) $$USER"
	LIMA_INSTANCE=dev lima sh -c "mkdir -p ~/.ssh"
	LIMA_INSTANCE=dev lima cp /home/deck/.ssh/id_rsa /home/deck.linux/.ssh/id_rsa
	LIMA_INSTANCE=dev lima cp /home/deck/.ssh/id_rsa.pub /home/deck.linux/.ssh/id_rsa.pub
	LIMA_INSTANCE=dev lima sudo systemctl start docker.service
	LIMA_INSTANCE=dev lima sudo systemctl enable docker.service
	LIMA_INSTANCE=dev lima sh -c "sudo usermod -aG docker $$USER"
	LIMA_INSTANCE=dev lima sh -c "sudo chmod 666 /var/run/docker.sock"

	LIMA_INSTANCE=dev lima sh -c 'if ! grep -q "cd ~/repos/$(PROJECT_NAME)" ~/.bashrc; then \
        echo "cd ~/repos/$(PROJECT_NAME)" >> ~/.bashrc; \
    fi'

	LIMA_INSTANCE=dev lima sh -c 'if ! grep -q "source ~/.bashrc" ~/.zshrc; then \
        echo "source ~/.bashrc" >> ~/.zshrc; \
    fi'


repo:
	LIMA_INSTANCE=dev lima git config --global user.name "Andrew Sokolov"
	LIMA_INSTANCE=dev lima git config --global user.email "mr.andrewsokolov@gmail.com"
	LIMA_INSTANCE=dev lima mkdir /home/$USER/repos
	LIMA_INSTANCE=dev lima git clone git@github.com:andrewsokolov/$(PROJECT_NAME).git /home/ubuntu/repos/$(PROJECT_NAME)
