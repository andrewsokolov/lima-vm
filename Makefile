start:
	limactl start template://archlinux --name dev

init:
	LIMA_INSTANCE=dev lima sudo pacman-key --init
	LIMA_INSTANCE=dev lima sudo pacman-key --populate archlinux
	LIMA_INSTANCE=dev lima sudo pacman -Syu
	LIMA_INSTANCE=dev lima sudo pacman -Su git wget docker zsh make
	LIMA_INSTANCE=dev lima sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
	LIMA_INSTANCE=dev lima sh -c "sudo chsh -s $$(which zsh) $$USER"
	LIMA_INSTANCE=dev lima sh -c "mkdir -p ~/.ssh"
	LIMA_INSTANCE=dev lima cp /home/deck/.ssh/id_rsa /home/deck.linux/.ssh/id_rsa
	LIMA_INSTANCE=dev lima cp /home/deck/.ssh/id_rsa.pub /home/deck.linux/.ssh/id_rsa.pub


