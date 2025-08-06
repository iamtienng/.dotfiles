Install Brew
Install oh-my-zsh
Install evalcache
Install powerlevel10k
Set OLLAMA_HOST in `~/.zshenv`

```sh
sudo apt update
sudo apt upgrade
brew bundle --file=Brewfile
stow .
ln -s ~/.config/zshrc/.zshrc ~/.zshrc
```
