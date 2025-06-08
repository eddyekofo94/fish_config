#  NOTE: 2023-09-28 - This is needed when loading fzf file

# https://github.com/junegunn/fzf/wiki/Color-schemes#color-configuration
# interactive color picker for fzf themes: https://minsw.github.io/fzf-color-picker/
#
# REF:
# https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings
# https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236
# https://sourcegraph.com/github.com/junegunn/fzf/-/blob/ADVANCED.md#--height
# https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/#4-preview-files-before-selecting-them

function _fzf_compgen_path
    rg --files --glob "!.git" . "$1"
end

function _fzf_git_status_git
    git -c color.status=always status --short | fzf --ansi \
        --preview '(git diff --color=always -- {-1} | sed 1,4d; [[ ! -d {-1} ]] && bat --color=always {-1}) | head -500' \
        --bind='ctrl-o:execute(${EDITOR:-vim} {+})'
end

function _fzf_compgen_dir
    fd --type d --hidden --follow --exclude ".git" . "$1"
end

#function _fzf_complete_git
#    _fzf_complete -- "$argv" < <(
#        echo log
#        echo diff
#    )
#end

#function _fzf_complete_git
#    _fzf_complete -- "$argv" < <(
#        git --help -a | grep -E '^\s+' | awk '{print $1}'
#    )
#end

# TODO:
# https://www.reddit.com/r/vim/comments/10mh48r/fuzzy_search/
# perf gains to be had here: https://github.com/ranelpadon/configs/blob/master/zshrc/rg_fzf_bat.sh

# if has rg; then
#     set -Ux FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --no-require-git --no-ignore --hidden --follow --glob "!{.git|.npm|node_modules}/*" 2> /dev/null'
# fi


set -q FZF_COMMON_OPTIONS; or set -Ux FZF_COMMON_OPTIONS "--inline-info=right \
    --height 96% \
    --preview-window=right,55%,border-sharp,nocycle \
    --select-1 \
    --border=none \
    --no-separator \
    --ansi \
    --multi \
    --reverse \
    --extended \
    --bind=ctrl-space:toggle \
    --bind=ctrl-a:select-all \
    --bind=ctrl-d:deselect-all \
    --bind=ctrl-t:toggle-all \
    '--bind=ctrl-o:execute-silent($EDITOR {})+abort' \
    --bind=ctrl-i:ignore,ctrl-k:ignore \
    --bind=ctrl-j:down,ctrl-k:up \
    --bind=ctrl-u:preview-up,ctrl-d:preview-down \
    --bind=esc:abort \
    --bind=ctrl-c:abort \
    --bind=?:toggle-preview \
    --preview='$FZF_PREVIEW_COMMAND' \
    --cycle \
    --margin=1,0,0 \
    --padding=0,0 \
    --prompt='∷ '"

command -v bat >/dev/null && command -v eza >/dev/null && set -Ux FZF_DEFAULT_OPTS "$FZF_COMMON_OPTIONS"

set -q FZF_PREVIEW_COMMAND; or set -Ux FZF_PREVIEW_COMMAND '_fzf_preview_command {}'

set -Ux FZF_CTRL_T_OPTS "--min-height 30 \
    --height 85% \
    --preview-window noborder --preview '_fzf_preview_command {}'"

# alts: 󰛄
# --bind=ctrl-f:page-down,ctrl-b:page-up
# --bind=ctrl-u:preview-up,ctrl-d:preview-down
# --preview='bat --color=always --style=header,grid --line-range :300 {}'
# --no-multi
# --reverse
# --height=22%

# Catpuccin FZF colours
set -Ux FZF_CATPPUCCIM_THEME "\
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

function _fzf_catppuccin_theme
    set -Ux FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
    --color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8 \
    --color=border:#45475a \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
end

# CTRL-/ to toggle small preview window to see the full command
# CTRL-Y to copy the command into clipboard using pbcopy
set -Ux FZF_CTRL_R_OPTS "--header='command history (Press CTRL-y to copy command into clipboard)' \
    --inline-info \
    --height=70% \
    --select-1 \
    --ansi \
    --reverse \
    --extended \
    --preview 'echo {}' --preview-window down:3:wrap \
    --bind 'ctrl-/:toggle-preview' \
    --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' \
    --color header:italic"

#_fzf_catppuccin

if command -q fd
    # FZF
    # Setting fd as the default source for fzf
    set -Ux FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    set -Ux FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

    set -Ux FZF_ALT_C_OPTS "--preview 'eza -T --icons auto --color=always {}' --height=60%"
    set -Ux FZF_ALT_C_COMMAND "fd -t d -d 1 --follow --hidden --color=always --no-ignore-vcs --exclude 'Library'"
end

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
function _fzf_comprun
    set -l command "$argv[1]"

    switch $command
        case git
            git --help -a | grep -E '^\s+' | awk '{print $1}' | fzf "$argv"
        case cd
            fzf --preview 'eza -T --icons auto --color=always {} | head -200' "$argv"
        case set -Ux or unset
            fzf --preview "eval 'echo\$' {}" "$argv"
        case ssh
            fzf --preview 'dig {}' "$argv"
        case tree
            find . -type d | fzf --preview 'eza -T --icons auto {}' --color=always "$argv"
        case '*'
            fzf "$argv"
    end
end

_fzf_catppuccin_theme

set -Ux FZF_PREVIEW_LINES -200
