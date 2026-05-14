```sh
pacman -S stow
pacman -S git
pacman -S openssh
# for WSL2
# Powershell
choco install npiperelay
# WSL2
pacman -S socat
ln -s /mnt/c/ProgramData/chocolatey/lib/npiperelay/tools/npiperelay.exe /usr/local/bin/npiperelay.exe
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
ss -a | grep -q "$SSH_AUTH_SOCK"
if [ $? -ne 0 ]; then
    rm -f $SSH_AUTH_SOCK
    socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork \
    EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &
fi
# end for WSL2
stow .
# install zsh
# install oh-my-zsh
# install powerlevel10k
# install evalcache
ln -s ~/.config/zshrc/.zshrc ~/.zshrc
pacmanup
yayup
fcitx5-configtool
```
