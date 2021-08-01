function fuzzy-pass() {
  DIR=$(pwd)
  cd "${HOME}/.password-store"
  PASSFILE=$(tree -Ffi | grep '.gpg' | sed 's/.gpg$//g' | sed 's/^..//' | fzf)

  [ -z "$PASSFILE" ] && return 0

  PASSDATA="$(pass ${PASSFILE})"
  PASS="$(echo "${PASSDATA}" | head -n 1)"
  LOGIN="$(echo "${PASSDATA}" | egrep -i "login:|username:|user:" | head -n 1 | cut -d' ' -f2-)"
  if [ -z "${LOGIN}" ] && [ -n "${PASS}" ]; then
    LOGIN=${PASSFILE##*/}
  fi
  EMAIL="$(echo "${PASSDATA}" | egrep -i "email:" | head -n 1 | cut -d' ' -f2-)"
  URL="$(echo "${PASSDATA}" | egrep -i "url:" | cut -d' ' -f2-)"
  if [ -z "${URL}" ]; then
    URL="$(basename $(dirname "${PASSFILE}"))"
    URL="$(echo "${URL}" | grep "\.")"
  fi

  cd ${DIR}

  ACTIONS="File"

  if [ -n "${URL}" ]; then
    ACTIONS="Url\n${ACTIONS}"
  fi
  if [ -n "${EMAIL}" ]; then
    ACTIONS="Email\n${ACTIONS}"
  fi
  if [ -n "${PASS}" ]; then
    ACTIONS="Password\n${ACTIONS}"
  fi
  if [ -n "${LOGIN}" ]; then
    ACTIONS="Login\n${ACTIONS}"
  fi

  CONTINUE=true

  while ${CONTINUE}; do
    ACTION=$(echo "${ACTIONS}" \
      | fzf --height 10 --border --header "Pass file ${PASSFILE}")
    case ${ACTION} in
      Login)
        echo "${LOGIN}" | clipcopy
        echo "Copied Login '${LOGIN}' to clipboard"
        ;;
      Password)
        pass --clip "${PASSFILE}" 1>/dev/null
        echo "Copied Password to clipboard (clear in 45 seconds)"
        ;;
      Url)
        echo "${URL}" | clipcopy
        echo "Copied Url '${URL}' to clipboard"
        ;;
      File)
        pass "${PASSFILE}"
        ;;
      Email)
        echo "${EMAIL}" | clipcopy
        echo "Copied Email '${EMAIL}' to clipboard"
        ;;
      *)
        CONTINUE=false
        ;;
    esac
  done

}

alias fzp=fuzzy-pass
