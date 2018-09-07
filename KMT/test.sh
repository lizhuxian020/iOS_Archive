#!/bin/sh


source ./tool.sh

cd "/Users/mac/KMTProject"

TaskWorkSpacePath="/Users/mac/KMTProject"

scheme=""
# ============= 获取schemeName =============
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
scheme=${each}
fi
done
# ============= ============= =============
ProjectPath="${TaskWorkSpacePath}/${scheme}"

InfoPlistPath="${ProjectPath}/${scheme}/Info.plist"
#TODO: 这里要判断infoPlist是否存在, 现在暂时不管
bundleID=""
# ============= 获取BundleID =============
bundleID=$(/usr/libexec/PlistBuddy -c "Print CFBundleURLTypes:0:CFBundleURLSchemes:0" "${InfoPlistPath}")
echo $bundleID





#if [[ ${dir} =~ "test.sh" ]];then
#echo "contain test"
#else
#echo "no"
#fi
#
#str="this is a string"
#[[ $str =~ "this" ]] && echo "$str contains this"
#[[ $str =~ "that" ]] || echo "$str does NOT contain that"