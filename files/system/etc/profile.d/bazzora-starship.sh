# shellcheck shell=bash
# Active le prompt Starship (profil Nerd Fonts) dans les shells Bash interactifs.
# La complétion est fournie par bash-completion (/etc/profile.d/bash_completion.sh).

if [ -n "${BASH_VERSION:-}" ] && [[ $- == *i* ]] && [ "${TERM:-dumb}" != "dumb" ]; then
    if command -v starship >/dev/null 2>&1 && [ -z "${STARSHIP_SHELL:-}" ]; then
        eval "$(starship init bash)"
    fi
fi
