#!/usr/bin/env bash

findProjName(){

    dir=$(ls)

    x="${dir}"

    OLD_IFS="$IFS"
    IFS="
    "
    array=($x)
    IFS="$OLD_IFS"

    for each in ${array[*]}
    do
    if [ ${each} != "KMTGlobe" ];then
    echo "findout!: ${each}"
    return "$each"
    fi
    done



}