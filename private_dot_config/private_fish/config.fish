# Setup asdf
source ~/.asdf/asdf.fish

# Setup paths
fish_add_path ~/go/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin

# Create aliases
alias lg=lazygit
alias lzd=lazydocker

if status is-interactive
	# Commands to run in interactive sessions can go here
end

