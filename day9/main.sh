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

# Same thing + check if the whole data fits in the available zone
secondPart() {
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

    # If for a size n we need to go at least to i, then cache it
    declare -A cache
    local maxi=10
    declare -A cache
    local maxi=10
    findFirstPlace() {
        local n=$1
        local length=${#available[@]}
        local start=${cache[$n]:-0}
        local windowStart=$start
        local currentLength=0
        for ((i = start; i < length; i++)); do
            if ((available[i] == -1)); then
                windowStart=$((i + 1))
                currentLength=0
                continue
            fi
            if ((i > windowStart && available[i - 1] + 1 != available[i])); then
                windowStart=$i
                currentLength=1
            else
                currentLength=$((i - windowStart + 1))
            fi
            if ((currentLength == n)); then
                for ((k = n; k <= maxi; k++)); do
                    cache[$k]=$((windowStart + n))
                done
                echo $windowStart
                return 0
            fi
        done
        echo -1
    }

    local lastFileID=$((fileID - 1))
    local sum=0
    for ((fileID = $lastFileID; fileID >= 0; fileID--)); do
        IFS=',' read -r -a array <<<"${positions[$fileID]}"
        local n=${#array[@]}

        if ((fileID % 100 == 0)); then
            echo $fileID
        fi

        local firstPlace=$(findFirstPlace $n)
        if ((firstPlace == -1 || available[$firstPlace] >= array[0])); then
            for ((i = 0; i < ${#array[@]}; i++)); do
                ((sum += fileID * array[i]))
            done
        else
            for ((i = 0; i < ${#array[@]}; i++)); do
                local current=${available[$firstPlace + i]}
                ((sum += fileID * current))
                available[$((firstPlace + i))]=-1
            done
        fi
    done

    echo $sum

    return 0
}

problem=$(parseInput "input.txt")

#firstPart $problem
secondPart $problem
