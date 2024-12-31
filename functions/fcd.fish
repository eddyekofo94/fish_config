function fcd -d "cd into the directory of the selected file"
    set -l file
    set file (fzf +m -q "$argv" \
           --preview-window='right:hidden:wrap' \
           --bind=ctrl-v:toggle-preview \
           --bind=ctrl-x:toggle-sort \
           --header='(view:ctrl-v) (sort:ctrl-x)' \
       )

    #--preview="${FZF_PREVIEW_CMD}" \
    if test (count $file) -gt 0
        cd (dirname "$file") || return
    end
end
