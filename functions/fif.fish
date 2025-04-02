function fif -d "find entry in files"
    # Switch between Ripgrep mode and fzf filtering mode (CTRL-T)
    rm -f /tmp/rg-fzf-{r,f}
    set -x RG_PREFIX "rg --column --line-number --no-heading --color=always --smart-case "
    #INITIAL_QUERY="${*:-}"
    fzf --ansi --disabled --query "$argv" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --bind 'ctrl-t:transform:[ not $FZF_PROMPT != ripgrep ] &&
        echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
        echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --prompt '1. ripgrep> ' \
        --delimiter : \
        --border-label="| Find In Files |" \
        --header 'CTRL-T: Switch between ripgrep/fzf' \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become($EDITOR {1} +{2})'
end
