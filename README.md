# Prepare .zshenv file

```sh
echo "XDG_CONFIG_HOME=\"$HOME/.config\"" >> $HOME/.zshenv
echo "ZDOTDIR=\"\$XDG_CONFIG_HOME/zshrc\"" >> $HOME/.zshenv
XDG_CONFIG_HOME="$HOME/.config" >> /etc/zshenv
ZDOTDIR="$XDG_CONFIG_HOME/zshrc" >> /etc/zshenv
```

# Install using stow

```sh
stow .
```

# Sync Lazy Vim Plugins

```sh
:Lazy sync
```
