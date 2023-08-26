MAKEFLAGS += --silent
SHELL := /usr/bin/env fish

.PHONY: all
all: deps packages config dotfiles

.PHONY: deps apt adsf rust pipx
deps: apt asdf rust pipx

apt:
	sudo apt update
	sudo apt install -y \
		build-essential \
		curl \
		golang-go \
		libbz2-dev \
		libffi-dev \
		liblzma-dev \
		libncursesw5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		libxmlsec1-dev \
		python3-pip \
		python3-venv \
		ranger \
		tk-dev \
		tree \
		unixodbc-dev \
		unzip \
		xz-utils \
		zlib1g-dev \
		&& exit 0
	sudo apt upgrade -y
	sudo apt autoremove -y

asdf:
	rm -rf ~/.asdf ~/.config/fish/completions
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
	echo "source ~/.asdf/asdf.fish" >> ~/.config/fish/config.fish
	mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions

rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	echo "fish_add_path ~/.cargo/bin" >> ~/.config/fish/config.fish

pipx:
	python3 -m pip install --user pipx
	python3 -m pipx ensurepath
	~/.local/bin/register-python-argcomplete --shell fish pipx >~/.config/fish/completions/pipx.fish

.PHONY: packages asdf-packages go-packages rust-packages pipx-packages
packages: asdf-packages go-packages rust-packages pipx-packages

asdf-packages:
	asdf plugin add chezmoi || exit 0
	asdf plugin add python || exit 0
	asdf install chezmoi 2.38.0
	asdf global chezmoi 2.38.0
	asdf install python 3.11.5

go-packages:
	go install github.com/jesseduffield/lazygit@latest
	go install github.com/jesseduffield/lazydocker@latest

rust-packages:
	cargo install difftastic
	cargo install vivid

pipx-packages:
	pipx install ipython
	pipx install hatch

.PHONY: config
config:
	set -Ux LS_COLORS (vivid generate ~/.config/vivid/themes/kanagawa.yml)
	git config --global init.defaultBranch main
ifdef GIT_NAME
	git config --global user.name $(GIT_NAME)
endif
ifdef GIT_MAIL
	git config --global user.email $(GIT_MAIL)
endif

.PHONY: dotfiles
dotfiles:
	chezmoi -v apply

.PHONY: docker
docker:
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh ./get-docker.sh
	sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
	sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
	sudo usermod -a -G docker $$USER
	rm -f get-docker.sh
