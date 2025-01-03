function zd -d "z - cd into 'frecency' folder"
    set IFS '\n'

    set -l dir (
    zoxide query -l \
      | fzf \
          --reverse -1 \
          --no-sort \
          --no-multi \
          --tiebreak=index \
          --query "$argv[1]" \
          --preview-window='right:hidden:wrap' \
          --bind=ctrl-v:toggle-preview \
          --bind=ctrl-s:toggle-sort \
          --header='(view:ctrl-v) (sort:ctrl-s)' \
          #--preview "$FZF_PREVIEW_CMD" \
      )

    if test (count $dir ) -gt 0
        echo "cd $dir"
        cd $dir
    end

end
