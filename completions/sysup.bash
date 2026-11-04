# bash completion for sysup
_sysup() {
    local cur prev steps opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    steps="news mirrors keyring packages flatpak snap firmware devtools plugins dotfiles extra clean checks"
    opts="-y --yes -n --dry-run -c --check -d --deep --devel --no-clean --only --skip --helper
          -l --list-steps --config --edit-config --no-color -h --help -V --version"
    case $prev in
        --only|--skip)
            local prefix=${cur%,*}
            [[ $cur == *,* ]] && prefix+="," || prefix=""
            mapfile -t COMPREPLY < <(compgen -P "$prefix" -W "$steps" -- "${cur##*,}")
            compopt -o nospace 2>/dev/null
            return ;;
        --helper) mapfile -t COMPREPLY < <(compgen -W "paru yay pikaur trizen pacman" -- "$cur"); return ;;
        --config) mapfile -t COMPREPLY < <(compgen -f -- "$cur"); return ;;
    esac
    mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
}
complete -F _sysup sysup
