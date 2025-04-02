
function fgr -d "fzf - git reset"
    git rev-parse --git-dir >/dev/null 2>&1 || { echo "You are not in a git repository" && return }
    set -l files (_fzf_git_status_git | cut -c4-) #get file from fzf

    if test (count $files) -gt 0
        for file in $files
            #git rm --cached --force -- $file
            git checkout -- $file
        end
    end
end
