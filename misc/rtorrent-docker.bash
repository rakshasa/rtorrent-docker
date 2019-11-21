# bash completion for rtorrent-docker

# argument helper functions

_rtorrent_docker__rdo_compilers() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))

  if (( ${iword} == ${cword} )); then
    commands=(clang gcc)
  fi
}

_rtorrent_docker__rdo_docker_args() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))

  if (( ${iword} == ${cword} )); then
    COMPREPLY=($(compgen -W "$("${words[0]}" docker args)" -S= -- "${cur}"))
    _rtorrent_docker__nospace
    return 1
  fi
}

_rtorrent_docker__rdo_docker_context_types() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))

  if (( ${iword} == ${cword} )); then
    commands=($("${words[0]}" docker context types))
  fi
}

_rtorrent_docker__rdo_docker_images() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))

  if (( ${iword} == ${cword} )); then
    commands=($("${words[0]}" docker images))
  fi
}

_rtorrent_docker__rdo_docker_targets() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))

  if (( ${iword} == ${cword} )); then
    commands=($("${words[0]}" docker targets))
  fi
}

# completion rdo layer

_rtorrent_docker__rdo() {
  if [[ "${word}" == -* ]]; then
    flags=(--debug --help)
  else
    commands=(bash build destroy docker env git init machine tags)
  fi
}

# completion do build layer

_rtorrent_docker__rdo_build() {
  if [[ "${word}" == -* ]]; then
    flags=(--compiler --dry-run --help)
    arg_funcs+=(
      --compiler##rdo_compilers
    )
  else
    commands=(all check compile recompile)
  fi
}

# completion do docker layer

_rtorrent_docker__rdo_docker() {
  if [[ "${word}" != -* ]]; then
    commands=(args build children clean context images stage targets)
    arg_funcs+=(
      children##rdo_docker_images
    )
  fi
}

_rtorrent_docker__rdo_docker_build__flags() {
  flags=(
    --base-image
    --build-arg
    --context
    --dry-run
    --help
    --no-cache
    --post-exec
    --repository
    --rsync-verbose
    --stage-image
    --tag
    --tag-append
  )
  arg_funcs+=(
    --base-image##rdo_docker_targets
    --build-arg##rdo_docker_args
    --stage-image##rdo_docker_targets
  )
}

_rtorrent_docker__rdo_docker_build() {
  if [[ "${word}" != -* ]]; then
    commands=($("${words[0]}" docker targets))
  else
    _rtorrent_docker__rdo_docker_build__flags
  fi
}

_rtorrent_docker__rdo_docker_clean() {
  commands=(all)
}

_rtorrent_docker__rdo_docker_context() {
  if [[ "${word}" != -* ]]; then
    commands=(build clean types)
    arg_funcs+=(
      init##rdo_docker_context_types
    )
  fi
}

_rtorrent_docker__rdo_docker_context_build() {
  if [[ "${word}" != -* ]]; then
    commands=($("${words[0]}" docker targets))
  else
    _rtorrent_docker__rdo_docker_build__flags

    flags+=(
      --context-args
      --context-name
      --context-type
    )
  fi
}

_rtorrent_docker__rdo_docker_stage() {
  if [[ "${word}" != -* ]]; then
    commands=($("${words[0]}" docker targets))
  else
    _rtorrent_docker__rdo_docker_build__flags
  fi
}

# completion do env layer

_rtorrent_docker__rdo_env() {
  if [[ "${word}" == -* ]]; then
    flags=(--help)
  else
    commands=(create)
  fi
}

# completion do env layer

_rtorrent_docker__rdo_init() {
  commands=(default machine)
}

# completion do git layer

_rtorrent_docker__rdo_git() {
  if [[ "${word}" == -* ]]; then
    flags=(--help)
  else
    commands=(clone)
  fi
}

# completion do machine layer

_rtorrent_docker__rdo_machine() {
  if [[ "${word}" == -* ]]; then
    flags=(--help)
  else
    commands=(create current destroy start status stop)
  fi
}

# completion do tags layer

_rtorrent_docker__rdo_tags() {
  if [[ "${word}" == -* ]]; then
    flags=(--help)
  else
    commands=(docker libtorrent rtorrent)
  fi
}

# completion function
#
# https://github.com/rakshasa/bash-completion-template
#
# NAMESPACE=rtorrent_docker
# COMMAND=rdo
# EXECUTABLE="rdo"

_rtorrent_docker_rdo() {
  COMPREPLY=()

  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword
  local commands flags arg_funcs
  local command_current=rdo command_pos=0 iword=0 cskip=0

  for (( iword=1; iword <= ${cword}; ++iword)); do
    local word=${words[iword]}
    local completion_func=_rtorrent_docker__${command_current}

    commands=() flags=() arg_funcs=()

    if ! declare -F "${completion_func}" > /dev/null || ! ${completion_func}; then
      return 0
    fi

    if (( ${iword} == ${cword} )); then
      break
    elif [[ " ${commands[*]} " =~ " ${word} " ]]; then
      command_current=${command_current}_${word//-/_}
      command_pos=${iword}
    elif ! [[ " ${flags[*]} " =~ " ${word} " ]]; then
      return 0
    fi

    local arg_func=
    local iarg=

    for (( iarg=0; iarg < ${#arg_funcs[@]}; ++iarg )); do
      if [[ "${arg_funcs[iarg]}" =~ ^${word}##([^$]*)$ ]]; then
        arg_func="_rtorrent_docker__${BASH_REMATCH[1]//#/ }"
      elif [[ "${arg_funcs[iarg]}" =~ ^${word}#([^$]*)$ ]]; then
        arg_func="${BASH_REMATCH[1]//#/ }"
      fi
    done

    if [[ -n "${arg_func}" ]] && ! ${arg_func}; then
      return 0
    fi
  done

  local compreply=("${flags[*]}" "${commands[*]}")
  COMPREPLY=($(compgen -W "${compreply[*]}" -- "${cur}"))

  return 0
}

_rtorrent_docker__time() {
  _rtorrent_docker_rdo "${@}"
  #time _rtorrent_docker_rdo "${@}"
}

complete -F _rtorrent_docker__time rdo

# helper functions
#
# arg_funcs+=(--foo##skip)
# arg_funcs+=(--bar#_rtorrent_docker__skip)
# arg_funcs+=(--baz##compgen#-o#default)

_rtorrent_docker__compgen() {
  COMPREPLY=($(compgen $(printf "-o %s" "${@}")))
  return 1
}

_rtorrent_docker__compopt() {
  # compopt is not available in ancient bash versions (OSX)
  # so only call it if it's available
  type compopt &>/dev/null && compopt $(printf "-o %s" "${@}")
}

_rtorrent_docker__nospace() {
  # compopt is not available in ancient bash versions (OSX)
  # so only call it if it's available
  type compopt &>/dev/null && compopt -o nospace
}

_rtorrent_docker__word_skip() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))
}
