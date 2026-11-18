# Created by newuser for 5.9.2


HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
bindkey -e

zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit

eval "$(starship init zsh)"


source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

a() {
    local command="$1"
    shift

    case "$command" in
        "pc")
            echo "Select conventional commit type:"
            choice=$(gum choose "feat" "fix" "docs" "style" "refactor" "test" "chore")
            if [ -z "$choice" ]; then
                echo "No commit type selected. Aborted."
                return 1
            fi

            scope=$(gum input --placeholder "Scope (optional, press enter to skip)")

            msg=$(gum input --placeholder "Commit message")
            if [ -z "$msg" ]; then
                echo "Commit message cannot be empty."
                return 1
            fi

            if [ -n "$scope" ]; then
                full_msg="$choice($scope): $msg"
            else
                full_msg="$choice: $msg"
            fi

            echo "Committing with message: $full_msg"
            git add . && git commit -m "$full_msg"
            ;;
        *)
            echo "Unknown command: $command"
            return 1
            ;;
    esac
}


source ~/.config/zsh/functions/setImage.zsh
source ~/.config/zsh/functions/flashpico.zsh
source ~/.config/zsh/functions/flashesp.zsh

fastfetch
# Created by `pipx` on 2026-08-30 21:08:54
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/.local/npm/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"  # Android Studio default on Linux
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
