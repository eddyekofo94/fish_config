function gss -d "fzf git status"
    set -l prompt_add "Add > "
    set -l prompt_reset "Reset > "

    set -l git_root_dir (git rev-parse --show-toplevel)
    set -l git_unstaged_files "git -c color.status=always status --short $git_root_dir"

    # local git_staged_files='git status --short | grep "^[A-Z]" | awk "{print \$NF}"'
    set -l git_staged_files 'git -c color.status=always status --short | grep "^[A-Z]" | awk "{print \$NF}" 2> /tmp/fzf_error-log'

    set -l git_reset "git reset -- {2}"

    set -l test_echo "echo testing -n"

    # INFO: If file is contained in the unstaged add it or reset it!
    # set -l enter_cmd "($git_unstaged_files | grep {} && git add {2}) || $git_reset"

    set -l enter_cmd "($git_unstaged_files | grep {} && git add {2}) || $git_reset"
    # set -l enter_cmd "git add {2}"

    set -l preview_status_label "[ Diff ]"
    #set -l preview_status 'git diff --color=always -- {} | sed 1,4d; test -d {} && bat --color=always {} | head -500'
    set -l preview_status 'git diff --color=always -- {-1} | sed 1,4d; test ! -d {-1} && bat --color=always {-1} | head -500'

    set -l header "
		CTRL-S to switch between Add Mode and Reset mode
		CTRL_T for status preview | CTRL-F for diff preview | CTRL-B for blame preview
		ALT-E to open files in your editor
		ALT-C to commit | ALT-A to append to the last commits
        "

    set -l add_header "
		$header
		ENTER to add files
		ALT-P to add patch
        "

    set -l reset_header "
		$header
		ENTER to reset files
		ALT-D to reset and checkout files
        "
    set -l mode_reset "change-prompt($prompt_reset)+reload($git_staged_files)+change-header($reset_header)+unbind(alt-p)+rebind(alt-d)"
    set -l mode_add "change-prompt($prompt_add)+reload($git_unstaged_files)+change-header($add_header)+rebind(alt-p)+unbind(alt-d)"

    # --preview-label="$preview_status_label" \
    # --preview="$preview_status" \
    eval "$git_unstaged_files" | fzf \
        --multi \
        --reverse \
        --no-sort \
        --prompt="Add > " \
        --preview-label="$preview_status_label" \
        --preview="$preview_status" \
        --header "$add_header" \
        --header-first \
        --bind='start:unbind(alt-d)' \
        --bind="ctrl-t:change-preview-label($preview_status_label)" \
        --bind="ctrl-t:+change-preview($preview_status)" \
        --bind='ctrl-f:change-preview-label([ Status ])' \
        --bind='ctrl-f:+change-preview(git -c color.status=always status --short)' \
        --bind='ctrl-b:change-preview-label([ Blame ])' \
        --bind='ctrl-b:+change-preview(git blame --color-by-age {})' \
        --bind="ctrl-s:transform:[$FZF_PROMPT != '$prompt_add' ] && echo '$mode_reset' || echo '$mode_add'" \
        --bind="enter:execute($enter_cmd)" \
        # --bind="enter:+reload([$FZF_PROMPT != $prompt_add] && $git_unstaged_files || $git_staged_files)" \
        --bind="enter:+reload(["$FZF_PROMPT" != "$prompt_add"] && $git_unstaged_files || $git_staged_files)" \
        --bind="enter:+refresh-preview" \
        --bind='alt-p:execute(git add --patch {+})' \
        --bind="alt-p:+reload($git_unstaged_files)" \
        --bind="alt-d:execute($git_reset && git checkout {+})" \
        --bind="alt-d:+reload($git_staged_files)" \
        --bind='alt-c:execute(git commit)+abort' \
        --bind='alt-a:execute(git commit --amend)+abort' \
        --bind='ctrl-o:become($EDITOR {2})' \
        --bind='f1:toggle-header' \
        --bind='f2:toggle-preview' \
        --bind='ctrl-y:preview-up' \
        --bind='ctrl-e:preview-down' \
        --bind='ctrl-u:preview-half-page-up' \
        --bind='ctrl-d:preview-half-page-down'
end
