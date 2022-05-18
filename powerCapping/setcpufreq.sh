#!/bin/bash

function check_env()
{
    return 0
    echo "CPU Manufacturer error." >&2
    return 1
}

function init()
{
    OPERATE_MODE=""
    OPERATE=""

    AVAILABLE_FREQS=(1.1 1.3 1.5 1.7 1.9 2.1)
    LENGTH=${#AVAILABLE_FREQS[@]}
    MIN_FREQ=${AVAILABLE_FREQS[0]}
    MAX_FREQ=${AVAILABLE_FREQS[$LENGTH - 1]}
}

function check_param()
{
    if [ $# -eq 1 ]; then
        if [ "$1" == "disable" ]; then
            OPERATE_MODE="$1"
            return 0
        fi
    elif [ $# -eq 2 ]; then
        if [ "$1" == "enable" ] && [ "$2" == "up" -o "$2" == "down" ]; then
            OPERATE_MODE="$1"
            OPERATE="$2"
            return 0
        fi
    fi

    echo "Parameter error." >&2
    return 1
}

function get_current_freq()
{
    echo "1.1"
}

function operate()
{
    if [ "${OPERATE_MODE}" == "disable" ]; then
        echo "cpupower frequency-set -g performance."
        return 0
    fi

    if [ "${OPERATE}" == "up" ]; then
        increase_freq
    else
        decrease_freq
    fi
}

function find_higher_freq()
{
    local freq="$1"

    for ((i=0; i<$LENGTH; i++))
    do
        tmp_freq=${AVAILABLE_FREQS[$i]}
        if [ $(echo "${tmp_freq} > ${freq}" | bc) -eq 1 ]; then
            echo "${tmp_freq}"
            return 0
        fi
    done
}

function find_lower_freq()
{
    local freq="$1"

    for ((i=$LENGTH-1; i>=0; i--))
    do
        tmp_freq=${AVAILABLE_FREQS[$i]}
        if [ $(echo "${tmp_freq} < ${freq}" | bc) -eq 1 ]; then
            echo "${tmp_freq}"
            return 0
        fi
    done
}

function increase_freq()
{
    local cur_freq

    cur_freq="$(get_current_freq)"

    if [ $(echo "${cur_freq} >= ${MAX_FREQ}" | bc) -eq 1 ]; then
        echo "No need to increase the cpu frequency.(${cur_freq}}GHz)"
        return 0
    fi

    dst_freq="$(find_higher_freq ${cur_freq})"
    echo "cpupower frequency-set -g userspace"
    echo "cpupower frequency-set -f ${dst_freq}G"
    echo "Increase the CPU frequency successfully.(${cur_freq}GHz to ${dst_freq}GHz)"
}

function decrease_freq()
{
    local cur_freq

    cur_freq="$(get_current_freq)"

    if [ $(echo "${cur_freq} <= ${MIN_FREQ}" | bc) -eq 1 ]; then
        echo "No need to decrease the cpu frequency.(${cur_freq}GHz)"
        return 0
    fi

    dst_freq="$(find_lower_freq ${cur_freq})"
    echo "cpupower frequency-set -g userspace"
    echo "cpupower frequency-set -f ${dst_freq}G"
    echo "Decrease the CPU frequency successfully.(${cur_freq}GHz to ${dst_freq}GHz)"
}

function main()
{
    check_env
    [ $? -eq 0 ] || exit 1

    init

    check_param "$@"
    [ $? -eq 0 ] || exit 1


    operate

}

main "$@"
