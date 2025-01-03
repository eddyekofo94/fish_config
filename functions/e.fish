function e -d "Open or change directory"
    set -l selection (fd --follow --exclude .git --strip-cwd-prefix  | fzf --multi --height=80% --border=sharp \
    #--preview='tree -C {}' --preview-window='45%,border-sharp' \
    --query="$argv" \
    --prompt='Dirs > ' \
    --bind='del:execute(rm -ri {+})' \
    --bind='ctrl-p:toggle-preview' \
    --bind='ctrl-d:change-prompt(Dirs > )' \
    --bind='ctrl-d:+reload(fd --type d)' \
    --bind='ctrl-d:+change-preview(eza -T --color=always {})' \
    --bind='ctrl-d:+refresh-preview' \
    --bind='ctrl-f:change-prompt(Files > )' \
    --bind='ctrl-f:+reload(fd --type f)' \
    --bind='ctrl-f:+change-preview(cat {})' \
    --bind='ctrl-f:+refresh-preview' \
    --bind='ctrl-a:select-all' \
    --bind='ctrl-x:deselect-all' \
    --header '
    CTRL-D to display directories | CTRL-F to display files
    CTRL-A to select all | CTRL-x to deselect all
    ENTER to edit | DEL to delete
    CTRL-P to toggle preview
    '
    )

    if test (count $selection) -gt 0
        if test -d "$selection"
            cd "$selection" || exit
        else
            eval "$EDITOR $selection"
        end
    end
end
