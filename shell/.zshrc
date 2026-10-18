# Portable zsh interactive configuration
if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

export EDITOR="nvim"
export VISUAL="nvim"

alias ls='ls --color=auto'
alias ll='ls -lah'
alias neobean='NVIM_APPNAME=linkarzu/dotfiles-latest/neovim/neobean nvim'
