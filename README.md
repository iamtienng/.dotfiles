Install Brew
Install oh-my-zsh
Install evalcache
Install powerlevel10k
Set OLLAMA_HOST in `~/.zshenv`

```sh
sudo apt update
sudo apt upgrade
```

```sh
ssh-keygen -t ed25519 -C ""
git config user.email ""
git config user.name ""
git config commit.gpgsign true
git config --global gpg.format ssh
git config --global user.signingkey /PATH/TO/.SSH/KEY.PUB
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

```sh
brew bundle --file=Brewfile
stow .
ln -s ~/.config/zshrc/.zshrc ~/.zshrc
```

Use lazygit at shell before using lazygit in neovim.
