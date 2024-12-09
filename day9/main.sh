#!/bin/bash

set -e
parseInput() {
    echo $(cat $1)
}

firstPart() {
    declare -A positions
    local line=$1
    local available=()
    local index=0
    local fileID=0
    local availableIndex=0
    local firstApparitions=()
    for ((i = 0; i < ${#line}; i++)); do
        char=${line:$i:1}

        if ((i % 2 != 0)); then
            for ((j = 0; j < $char; j++)); do
                available+=($((index + j)))
            done
        else
            local list=() # Local otherwise the list is used for all iterations
            for ((j = 0; j < $char; j++)); do
                list+=($((index + j)))
            done
            positions[$fileID]=$(
                IFS=','
                echo "${list[*]}"
            )
            ((fileID += 1))
        fi

        ((index += $char))
    done

    local freeAvailableIndex=0
    local lastFileID=$((fileID - 1))
    local sum=0
    local ignoreReordering=0
    for ((fileID = $lastFileID; fileID >= 0; fileID--)); do
        IFS=',' read -r -a array <<<"${positions[$fileID]}"

        for ((i = ${#array[@]} - 1; i >= 0; i--)); do
            local current=${available[$freeAvailableIndex]}
            if ((ignoreReordering == 0)); then
                ((sum += fileID * current))
            else
                ((sum += fileID * array[i]))
            fi
            ((freeAvailableIndex += 1))
            if ((freeAvailableIndex >= ${#available[@]})); then
                ignoreReordering=1
            elif ((${available[$freeAvailableIndex]} > ${array[i]})); then
                ignoreReordering=1
            fi
        done
    done

    echo $sum

    return 0
}

problem=$(parseInput "input.txt")

#firstPart $problem
secondPart $problem
