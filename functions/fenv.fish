function fenv -d "fzf the environment variables"
    set -l envs
    set envs (env | fzf +m \
                  --query="$argv" --no-multi --select-1 --exit-0 \
                  --preview 'echo {}' --preview-window down:3:wrap \
                  )

    echo (echo "$envs" | cut -d= -f2)
end
