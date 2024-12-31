function ufenv -d "fzf the unset environment variables"
    set -l envs
    set envs (env | fzf +m \
                  --query="$argv" --select-1 --exit-0 \
                  --bind=ctrl-x:execute(set --erase | echo {} | cut -d= -f1)+abort \
                  #--preview 'echo {}' --preview-window down:3:wrap \
                  )

    if test (count $envs) -gt 0
        set -l var (echo "$envs" | cut -d= -f1)

        echo "set --erase $var"
        set --erase $var
    end
end
