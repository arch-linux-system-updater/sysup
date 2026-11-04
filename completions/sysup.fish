# fish completion for sysup
set -l steps news mirrors keyring packages flatpak snap firmware devtools plugins dotfiles extra clean checks

complete -c sysup -f
complete -c sysup -s y -l yes        -d 'Never ask, pass --noconfirm to everything'
complete -c sysup -s n -l dry-run    -d 'Show what would run, change nothing'
complete -c sysup -s c -l check      -d 'Only list available updates'
complete -c sysup -s d -l deep       -d 'Deep clean'
complete -c sysup      -l devel      -d 'Also rebuild -git/VCS AUR packages'
complete -c sysup      -l no-clean   -d 'Skip the cleanup step'
complete -c sysup      -l only       -x -a "$steps" -d 'Run only these steps'
complete -c sysup      -l skip       -x -a "$steps" -d 'Skip these steps'
complete -c sysup      -l helper     -x -a 'paru yay pikaur trizen pacman' -d 'Force an AUR helper'
complete -c sysup -s l -l list-steps -d 'List all steps'
complete -c sysup      -l config     -r -F -d 'Read an extra config file'
complete -c sysup      -l edit-config -d 'Open your config in $EDITOR'
complete -c sysup      -l no-color   -d 'Disable colours'
complete -c sysup -s h -l help       -d 'Show help'
complete -c sysup -s V -l version    -d 'Show version'
