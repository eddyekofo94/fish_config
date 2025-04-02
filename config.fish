# conf.d runs first!

# https://fishshell.com/docs/current/tutorial.html
# https://github.com/jorgebucaran/fish-shell-cookbook
# https://github.com/fish-shell/fish-shell/blob/master/share/config.fish
# https://github.com/fish-shell/fish-shell/blob/da32b6c172dcfe54c9dc4f19e46f35680fc8a91a/share/config.fish#L257-L269

#
# Env
#

# Set vars for dotfiles and special dirs.
set -g ZDOTDIR $XDG_CONFIG_HOME/zsh
set -gx DOTFILES $HOME/.dotfiles

# Set initial working directory.
set -g IWD $PWD

if status is-interactive
    # Commands to run in interactive sessions can go here
    eval (zellij setup --generate-auto-start fish | string collect)
end

if status is-login
    # TODO: See how properly do this without the error on MacOS
    if string match -q -- "WSL*" $OS
        echo "It is wsl"
        # For Homebrew/Linuxbrew to work
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        # export PYTHONPATH=:~/.local/lib/python3.11/site-packages/:~/.local/lib/python3.11/site-packages/

        # WSL specidic aliases & abbrs
        alias docker='docker.exe'
        alias wsl='wsl.exe'
        abbr -a -- psh 'powershell.exe'

        # IMPORTANT: this seems to work on WSL, so keep it!
        fzf_configure_bindings --history=\cr --git_status=\cg --directory=\cp

        # Fix the VPN issue: For Amadeus
        abbr -a -- fnet 'cd $HOME/onedrive/VPN && powershell.exe -File setup-vpn.ps1'
    end

    # Enables vim keybindings
    #fish_vi_key_bindings --no-erase insert
    set fish_key_bindings fish_user_key_bindings

    # Emulates vim's cursor shape behavior
    # Set the normal and visual mode cursors to a block
    set fish_cursor_default block
    # Set the insert mode cursor to a line
    set fish_cursor_insert line
    # Set the replace mode cursor to an underscore
    set fish_cursor_replace_one underscore
    # The following variable can be used to configure cursor shape in
    # visual mode, but due to fish_cursor_default, is redundant here
    set fish_cursor_visual block

    # starship init fish | source

    # FZF
    #export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --no-require-git --no-ignore --hidden --follow --glob "!.git/*"'
    #export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    # set fzf_fd_opts --hidden --exclude=.git
end

set __file__ $HOME/.config/fish/config.fish

#
# Utils
#

# Initialize fuzzy finder.
if type -q fzf
    if not test -r $__fish_cache_dir/fzf_init.fish
        fzf --fish >$__fish_cache_dir/fzf_init.fish
    end
    source $__fish_cache_dir/fzf_init.fish
end

# Initialize zoxide for fast jumping with 'z'.
if type -q zoxide
    if not test -r $__fish_cache_dir/zoxide_init.fish
        zoxide init --cmd cd fish >$__fish_cache_dir/zoxide_init.fish
    end
    source $__fish_cache_dir/zoxide_init.fish
    zoxide init --cmd cd fish | source
end

#
# Prompt
#

# Disable new user greeting.
set fish_greeting

# Initialize starship.
if type -q starship
    #set -gx STARSHIP_CONFIG $__fish_config_dir/themes/starship.toml
    if not test -r $__fish_cache_dir/starship_init.fish
        starship init fish --print-full-init >$__fish_cache_dir/starship_init.fish
    end
    source $__fish_cache_dir/starship_init.fish
    #enable_transience
end


#
# Theme
#

fish_config theme choose $FISH_THEME

#  CLEAN_UP: 2024-12-29 - Remove when finished!
#set fish_key_bindings fish_user_key_bindings

# Local
#

#if test -r $DOTFILES.local/fish/config.fish
#    source $DOTFILES.local/fish/config.fish
#end

# Functions needed for !! and !$
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

# The bindings for !! and !$
if [ "$fish_key_bindings" = fish_vi_key_bindings ]
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end
