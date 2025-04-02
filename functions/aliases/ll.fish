# abbr -a -- ll 'eza --git --group-directories-first --icons --sort=modified --long --all --no-filesize --no-time --no-user --no-permissions'
function ll -d "list long"
    command eza --git --group-directories-first --icons --sort=modified --long --all --no-filesize --no-time --no-user --no-permissions
end
