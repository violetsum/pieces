# You can put files here to add functionality separated per file, which
# will be ignored by git.
# Files on the custom/ directory will be automatically loaded by the init
# script, in alphabetical order.

# For example: add yourself some shortcuts to projects you often work on.
#
# brainstormr=~/Projects/development/planetargon/brainstormr
# cd $brainstormr
#

function __add_path()
{
    local _path
    local last_flag

    _path=$(greadlink -f "$1")
    last_flag=$2

    # Path to be added to environment variable `PATH` does not exist
    [ ! -d "${_path}" ] && echo "__add_path: no such directory: ${_path}" && return 1

    # The environment variable `PATH` already contains path
    echo "${PATH}" | grep -q "${_path}" && return 0

    if [ "${last_flag}" = true ]; then
        export PATH="${PATH}:${_path}"
    else
        export PATH="${_path}:${PATH}"
    fi
}

function __get_env_var()
{
    /bin/bash -c "echo \$$1"
    # env | grep -E "^$1=" | awk -F '=' '{print $2}'
}

function afile()
{
    local file_name
    local fp1
    local fp2

    file_name="$1"
    fp1="$(greadlink -f "${file_name}")"
    fp2="$(which "${file_name}")"

    if [ -e "${fp1}" ]; then
        file "${fp1}"
    elif [ -e "${fp2}" ]; then
        file "${fp2}"
    else
        echo "${file_name}: cannot open \`${file_name}' (No such file or directory)" >&2
        return 1
    fi
}

function e()
{
    local key
    local res

    key="$1"

    res="$(__get_env_var "${key}")"
    [ -n "${res}" ] && echo "${res}" && return 0

    # convert "key" to upper case
    key="$(echo ${key} | tr "[:lower:]" "[:upper:]")"
    echo "$(__get_env_var "${key}")"
}

function lr()
{
    echo $?
}

function bb()
{
    local ret
    local count
    local param
    local index
    local target_br

    count=$#
    param=$*
    index=0

    git status >/dev/null 2>&1
    ret=$?
    [ ${ret} -ne 0 ] && return ${ret}

    if [ "${count}" -eq 0 ]; then
        for branch in $(git branch | sed 's/^[ *]*//')
        do
            echo -e "${index}\t${branch}"
            ((index=index+1))
        done 
    elif [ "${count}" -eq 1 ]; then
        if [[ ! ${param} =~ ^[0-9]+$ ]]; then
            return 0
        fi

        target_br=$(git branch | sed 's/^[ *]*//' | tail +${param} | head -1)
        [ -n "${target_br}" ] && git checkout "${target_br}"
    elif [ "${count}" -gt 1 ]; then
        echo "The number of parameters must not exceed 1" >&2
        return 1
    fi
}

function b()
{
    local count
    local param
    local index
    local PROJECT_DIR
    local branches_path

    count=$#
    param=$*
    index=0
    PROJECT_DIR=$(git rev-parse --show-toplevel)
    branches_path="${PROJECT_DIR}/.git/all_branches"

    [ -z "${PROJECT_DIR}" ] && return 128

    if [ "${count}" -eq 0 ]; then
        if [ ! -e "${branches_path}" ]; then
            git branch | sed 's/^[ *]*//' > "${branches_path}"
        fi

        while read branch
        do
            echo -e "${index}\t${branch}"
            ((index=index+1))
        done < "${branches_path}"
    elif [ "${count}" -eq 1 ]; then
        if [[ ! ${param} =~ ^[0-9]+$ ]]; then
            return 0
        fi

        while read branch
        do
            [ "${index}" -eq "${param}" ] && git checkout "${branch}"
            ((index = index + 1))
        done < "${branches_path}"
    elif [ "${count}" -gt 1 ]; then
        echo "The number of parameters must not exceed 1" >2
        return 1
    fi
}

# ===============================================================
# __add_path "/usr/local/opt/coreutils/libexec/gnubin"
__add_path "/usr/local/opt/gnu-sed/libexec/gnubin"
