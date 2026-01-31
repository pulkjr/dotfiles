# Dotfiles Management with Git

## Getting Started

Starting for the first time, run the following command to initialize the local repo.

```bash
git init --bare ~/.dotfiles
```

To manage your dotfiles with Git, you can create an alias in your shell configuration file (e.g., `.bashrc`, `.zshrc`) for easier access:

```bash
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

To checkout your dotfiles to your home directory, use the following command:

```bash
dotfiles checkout
```

## Restoring From Git

If you need to restore dotfile from the remote repository, you can clone it and checkout the files:

```bash
git clone --bare <repository-url> $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
```

Once you have checked out the git repository reload the shell to update validate the configuration.

Run the ~/.config/init/setup.sh script to configure the rest of the environment.

```bash
chmod +x ~/.config/init/setup.sh
~/.config/init/setup.sh
```

## Managed Dotfiles

Use the dotfiles command like any other git command to manage your dotfiles. For example, to add a new dotfile:

```bash
dotfiles add .vimrc
dotfiles commit -m "Add vimrc"
dotfiles push
```
