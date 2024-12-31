
#  TODO: 2024-12-31 - Turn to fish
function zdd -d "cd to selected directory"
    set -l dir
  set dir "(
    find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2> /dev/null \
      | fzf +m \
          --preview="eza --tree --color=always --icons auto {} | head -n $FZF_PREVIEW_LINES" \
          --preview-window='right:hidden:wrap' \
          --bind=ctrl-v:toggle-preview \
          --bind=ctrl-x:toggle-sort \
          --header='(view:ctrl-v) (sort:ctrl-x)' \
  )" || return

    cd "$dir" || return
end
