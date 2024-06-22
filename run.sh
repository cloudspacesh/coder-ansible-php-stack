#!/bin/bash
set -ex
set -o allexport

# cleanup colors from outputs
exec 2> >(sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' >&2)
exec > >(sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g')

pushd `dirname $0` > /dev/null;DIR=`pwd -P`;popd > /dev/null

[[ -f "${DIR}/.env" ]] && source "${DIR}/.env"

export DEBIAN_FRONTEND=noninteractive
export ANSIBLE_NOCOLOR=True
export ANSIBLE_CONFIG=${DIR}/ansible.cfg
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_NOCOWS=1

hash -r

if [[ "$OSTYPE" == "darwin"* ]]; then
  which envsubst > /dev/null || brew install gettext
else
  . /etc/os-release
  DISTRO=${ID_LIKE:-$ID}
  if [[ "debian" == $DISTRO ]]; then
    apt --fix-broken install
    which envsubst > /dev/null || apt update -qy && apt install -qy gettext
    which pip3 > /dev/null || apt update -qy && apt install -qy python3-pip
    which python3 > /dev/null || apt update -qy && apt install -qy python3
    which ansible-playbook > /dev/null || apt update -qy && apt install -qy ansible
  elif [[ "fedora" == $DISTRO ]]; then
    which envsubst > /dev/null || dnf install -qy gettext
    which pip3 > /dev/null || dnf install -qy python3-pip
    which python3 > /dev/null || dnf install -qy python3
    which ansible-playbook || dnf install -qy ansible
  else
    echo "Unsupported distro: $DISTRO"
    exit 1
  fi
fi

PYTHON_BIN=${PYTHON_BIN:-$(which brew > /dev/null 2>&1 && brew --prefix python3 > /dev/null 2>&1 && echo $(brew --prefix python3)/bin/python3 || echo $(which python3 > /dev/null && which python3 || echo "/usr/bin/python3"))}
ANSIBLE_PLAYBOOK_BIN=${ANSIBLE_PLAYBOOK_BIN:-$(which ansible-playbook 2>/dev/null || echo "${DIR}/ansible-playbook")}
ANSIBLE_PLAYBOOK_CMD=$(which ansible-playbook 2>/dev/null || echo "${PYTHON_BIN} ${DIR}/ansible-playbook")

ANSIBLE_HOST=${ANSIBLE_HOST:-localhost}
if [[ ! -z $ANSIBLE_HOST ]]; then
    if [[ ! -z $ANSIBLE_HOST ]] && [[ $ANSIBLE_HOST != "localhost" ]] && [[ $ANSIBLE_HOST != "127.0.0.1" ]]; then
        ANSIBLE_USER=${ANSIBLE_USER:-root}
        ANSIBLE_HOST=${ANSIBLE_HOST}
        ANSIBLE_CONNECTION=ssh
        export USER_DEVELOPER_UID=${USER_DEVELOPER_UID:-1000}
        export USER_DEVELOPER_USERNAME=${USER_DEVELOPER_USERNAME:-"developer"}
    else
        ANSIBLE_USER=${ANSIBLE_USER:-$USER}
        ANSIBLE_HOST=localhost
        ANSIBLE_CONNECTION=local

        export USER_DEVELOPER_UID=$(id -u ${USER_DEVELOPER_USERNAME:-$USER})
        export USER_DEVELOPER_USERNAME=$(id -nu $USER_DEVELOPER_UID)

        if [[ $USER_DEVELOPER_UID -lt 1000 ]] && [[ "$OSTYPE" != "darwin"* ]]; then
            if id -nu 1000 > /dev/null; then
                export USER_DEVELOPER_UID=1000
                export USER_DEVELOPER_USERNAME=$(id -nu 1000)
            else
                export USER_DEVELOPER_UID=1000
                export USER_DEVELOPER_USERNAME="developer"    
            fi
        fi
    fi
    mkdir -p "${DIR}/environments/${ANSIBLE_HOST}/group_vars"
    envsubst > "${DIR}/environments/${ANSIBLE_HOST}/hosts" <<CONFIG
[coder_workspace_vm]
${ANSIBLE_HOST} ansible_connection=${ANSIBLE_CONNECTION} ansible_user=${ANSIBLE_USER}
CONFIG

        envsubst > "${DIR}/environments/${ANSIBLE_HOST}/group_vars/coder_workspace_vm.yml" <<CONFIG
developer_username: "{{ lookup('env', 'USER_DEVELOPER_USERNAME') | default('developer', True) }}"
developer_uid: "{{ lookup('env', 'USER_DEVELOPER_UID') | default('1000', True) }}"
developer_password_hash: "{{ lookup('env', 'USER_DEVELOPER_PASSWORD_HASH') | default('', True) }}"
developer_github_accounts: []
developer_authorized_keys: []
github_oauth_token: "{{ lookup('env', 'GITHUB_OAUTH_TOKEN') | default('', True) }}"
CONFIG
fi

#pip3 install -r ${DIR}/requirements.txt
ANSIBLE_HOST_KEY_CHECKING=False ${ANSIBLE_PLAYBOOK_CMD} -i ${DIR}/environments/${ANSIBLE_HOST} ${DIR}/playbook.yml "$@"
