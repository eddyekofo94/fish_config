function _fzf_find_cat -d "fzf find cat"
    set -l file (
      fzf --query="$argv" --no-multi --select-1 --exit-0 \
          --preview 'bat --color=always --line-range :500 {}'
    )

    if test (count $file) -gt 0
        cat $file
    end
end

abbr fcat _fzf_find_cat
