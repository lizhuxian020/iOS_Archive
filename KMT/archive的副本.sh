#!/bin/sh

#测试包配置文件: 48570f66-3629-4f93-8c48-d782ad40f23d
#发布包配置文件:
echo "=============Configure export plist file============="
echo "===================Archive Script===================="
echo "Author:Mist"
echo "Version:1.1.0"
echo "===================Archive Script===================="
########################环境变量开始########################
#evn config
export LANG=en_US.UTF-8
#base config
#开发配置
provisioningProfile_dev="48570f66-3629-4f93-8c48-d782ad40f23d"
#开发证书
codeSignIdentity_dev="iPhone Developer: lei zhang (QYNKJGF5K9)"
#TODO: 生产配置
provisioningProfile_dis=""
#TODO: 生产证书
codeSignIdentity_dis=""
#TODO: bundleID配置(多个项目, 不同的bundleID?, 如何获取.?)
bundleID="com.kmt518.autoPackageProj"
#bugly配置
#BUGLY_APP_ID="71fd58c2b6"
#BUGLY_APP_KEY="ee03cb94-7d04-4849-8876-88bb7e1d5d26"
#根据参数判断
BUILD_MODE=$1
#-----mock----
BUILD_MODE="Develop"
#-----mock_end----
if [ $1 == "Develop" ]
then
#TODO: scheme名称(不同的项目, 不同的scheme, 如何获取.?)
scheme="autoPackageProj"
#测试配置
codeSignIdentity=$codeSignIdentity_dev
appStoreProvisioningProfile=$provisioningProfile_dev
#TODO: 这个是项目文件夹, (需要装着podfile的), 下面要用来pod install
schemeFolder="autoPackageProj"
#ICON_MODE="_Test"
#VERSIONSTRING="Beta"
elif [ $1 == "Release" ]
then
#scheme名称
scheme="autoPackageProj"
#发布配置
codeSignIdentity=$codeSignIdentity_dis
appStoreProvisioningProfile=$provisioningProfile_dis
schemeFolder="autoPackageProj"
#ICON_MODE="_PreRelease"
#VERSIONSTRING="RC"
else
echo "please append arguement eg. Develop Release"
exit 1
fi
#时间
archive_time=`date +%Y%m%d%H%M%S`
#TODO: 项目名称, 截取项目名称
project_name=autoPackageProj
#TODO: 工作空间名称, 也是截取, 拼接
workspaceName="autoPackageProj.xcworkspace"

#TODO: 项目路径, 本地路径, 获取SVN下的项目
project_dir="/Users/mac/MyOCProject/${schemeFolder}"
#包库的路径
autoPackageLipo_dir="/Users/mac/Desktop/AutoPackageLipo"
#具体的包路径: 包库/开发或发布/bundleID/时间戳
package_dir="${autoPackageLipo_dir}/${BUILD_MODE}/${bundleID}/${archive_time}"
#临时路径
temp_dir="${project_dir}/build/${project_name}.build/Debug/${project_name}.build"
#log文件基路径, 跟着每一个包
log_path="${package_dir}/log/${archive_time}"
#TODO: 配置是否为Debug, 根据入参判断, Release \ Debug
configuration="Debug"
#编译路径: 跟着每一个包
configurationBuildDir="${package_dir}/build"
#archive路径: 跟着每一个包
archivePath="${package_dir}/archive/${project_name}.xcarchive"
#dSYM文件路径: 是archive时候生成的, 跟着每一个archive
dSYMPath="${package_dir}/archive/dSYMs/${project_name}.dSYM"
#TODO: archiverOpt.plist配置(根据入参配置: development / app-store)
method=development
#签名风格
signingStyle=manual
#一个AppleID一个teamID, 改变不了的
teamID=5DHMHMME2V
#TODO: 这个也是要根据入参不同进行修改,
exportOptionsPlist="/Users/mac/Desktop/ExportOptions.plist"
#生成ipa路径
exportPath="${package_dir}/exportPackage"
#ipa路径
ipaPath="${exportPath}/${scheme}.ipa"
#altool路径
altoolPath="/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
#上传账号
account="开发者帐号"
password="开发者帐号密码或者临时密码"
########################环境变量结束########################

#TODO: 解锁KeyChain, 听说要解锁.? 先注释试试
#security unlock-keychain -p lizhuxian020 ~/Library/Keychains/login.keychain

#配置ipa输出的plistOp
echo "=============Configure export plist file============="
/usr/libexec/PlistBuddy -c "Set provisioningProfiles:$bundleID $appStoreProvisioningProfile" "$exportOptionsPlist"
/usr/libexec/PlistBuddy -c "Set method $method" "$exportOptionsPlist"
/usr/libexec/PlistBuddy -c "Set signingCertificate $codeSignIdentity_dis" "$exportOptionsPlist"
/usr/libexec/PlistBuddy -c "Set signingStyle $signingStyle" "$exportOptionsPlist"
/usr/libexec/PlistBuddy -c "Set teamID $teamID" "$exportOptionsPlist"
echo "===================Configure Done===================="

#创建日志路径
echo "==============Create log file directory=============="
mkdir -p ${log_path}
if [ $? -eq 0 ];then
echo "===================Create success===================="
else
echo "===================Create Failed====================="
echo "Please check the log file in ${log_path} for detail"
exit 1
fi

#cocoapods
echo "==============Cocoapod install process==============="
cd $project_dir
pod install >> ${log_path}/log_pods
if [ $? -eq 0 ];then
echo "===================Cocoapod Done====================="
else
echo "===================Create Failed====================="
cat ${log_path}/log_pods
echo "Please check the log file in ${log_path} for detail"
exit 1
fi

##画图标
#echo "==================Rendering Icon====================="
#if [ $1 != "release" ]; then
#convertPath=`which convert`
#if [[ ! -f ${convertPath} || -z ${convertPath} ]]; then
#echo "warning: Skipping Icon versioning, you need to install ImageMagick and ghostscript (fonts) first, you can use brew to simplify process:
#brew install imagemagick
#brew install ghostscript"
#exit -1;
#fi
# 说明
# VERSION    app-版本号
# ARCHIVE_VERSION  app-构建版本号
#VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${project_dir}/${project_name}/${scheme}.plist"`
#ARCHIVE_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleArchiveVersion" "${project_dir}/${project_name}/${scheme}.plist"`
#shopt -s extglob
#ARCHIVE_VERSION="${ARCHIVE_VERSION##*( )}"
#shopt -u extglob
#caption="V${VERSION}\n${VERSIONSTRING} ${ARCHIVE_VERSION}"
#function abspath() { pushd . > /dev/null; if [ -d "$1" ]; then cd "$1"; dirs -l +0; else cd "`dirname \"$1\"`"; cur_dir=`dirs -l +0`; if [ "$cur_dir" == "/" ]; then echo "$cur_dir`basename \"$1\"`"; else echo "$cur_dir/`basename \"$1\"`"; fi; fi; popd > /dev/null; }
#function processIcon() {
#base_file=$1
#temp_path=$2
#dest_path=$3
#if [[ ! -e $base_file ]]; then
#echo "error: file does not exist: ${base_file}"
#exit -1;
#fi
#if [[ -z $temp_path ]]; then
#echo "error: temp_path does not exist: ${temp_path}"
#exit -1;
#fi
#if [[ -z $dest_path ]]; then
#echo "error: dest_path does not exist: ${dest_path}"
#exit -1;
#fi
#file_name=$(basename "$base_file")
#final_file_path="${dest_path}/${file_name}"
#base_tmp_normalizedFileName="${file_name%.*}-normalized.${file_name##*.}"
#base_tmp_normalizedFilePath="${temp_path}/${base_tmp_normalizedFileName}"
##初始化
#xcrun -sdk iphoneos pngcrush -revert-iphone-optimizations -q "${base_file}" "${base_tmp_normalizedFilePath}"
#width=`identify -format %w "${base_tmp_normalizedFilePath}"`
#height=`identify -format %h "${base_tmp_normalizedFilePath}"`
#band_height=$(($height / 3))
#band_position=$(($height - $band_height))
#point_size=$(($width * 14 / 100))
#text_position=$(($band_position + (($band_height / 2) - ($point_size * 3 / 2))))
##
##半透明渲染文字
##
#convert "${base_tmp_normalizedFilePath}" -blur 10x8 /tmp/blurred.png
#convert /tmp/blurred.png -gamma 0 -fill white -draw "rectangle 0,$band_position,$width,$height" /tmp/mask.png
#convert -size ${width}x${band_height} xc:none -fill 'rgba(0,0,0,0.2)' -draw "rectangle 0,0,$width,$band_height" /tmp/labels-base.png
#convert -background none -size ${width}x${band_height} -pointsize $point_size -fill white -gravity center -gravity South caption:"$caption" /tmp/labels.png
#convert "${base_tmp_normalizedFilePath}" /tmp/blurred.png /tmp/mask.png -composite /tmp/temp.png
#rm /tmp/blurred.png
#rm /tmp/mask.png
##
##合成图片
##
#filename=New"${base_file}"
#convert /tmp/temp.png /tmp/labels-base.png -geometry +0+$band_position -composite /tmp/labels.png -geometry +0+$text_position -geometry +${w}-${h} -composite -alpha remove "${final_file_path}"
## clean up
#rm /tmp/temp.png
#rm /tmp/labels-base.png
#rm /tmp/labels.png
#rm "${base_tmp_normalizedFilePath}"
#}
## Process all app icons and create the corresponding internal icons
## icons_dir="${SRCROOT}/Images.xcassets/AppIcon.appiconset"
#icons_path="${project_dir}/${project_name}/Assets.xcassets/AppIcon${ICON_MODE}.appiconset"
#icons_dest_path="${project_dir}/${project_name}/Assets.xcassets/AppIcon${ICON_MODE}-Internal.appiconset"
#icons_set=`basename "${icons_path}"`
#tmp_path="${temp_dir}/IconVersioning"
#mkdir -p "${tmp_path}"
#if [[ $icons_dest_path == "\\" ]]; then
#echo "error: destination file path can't be the root directory"
#exit -1;
#fi
#rm -rf "${icons_dest_path}"
#cp -rf "${icons_path}" "${icons_dest_path}"
## Reference: https://askubuntu.com/a/343753
#find "${icons_path}" -type f -name "*.png" -print0 |
#while IFS= read -r -d '' file; do
#echo "$file"
#processIcon "${file}" "${tmp_path}" "${icons_dest_path}"
#done
#fi
#echo "===============Rendering Icon Done==============="

#清理构建
echo "=============Cleanup previous build file============="
rm -rf ./build
xcodebuild clean -configuration "$configuration" -alltargets >> ${log_path}/log_clean
if [ $? -eq 0 ];then
echo "===================Cleanup Done======================"
else
echo "===================Cleanup Failed===================="
cat ${log_path}/log_clean
echo "Please check the log file in ${log_path} for detail"
exit 1
fi

#更新build
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $archive_time" "${base_dir}/workspace/${schemeFolder}/Telework/$scheme.plist"

#编译
echo "=================Build process start================="
xcodebuild archive -workspace "$workspaceName" -scheme "$scheme" -configuration "$configuration" -archivePath "$archivePath" CONFIGURATION_BUILD_DIR="$configurationBuildDir" CODE_SIGN_IDENTITY="$codeSignIdentity" PROVISIONING_PROFILE_SPECIFIER="$appStoreProvisioningProfile" DEBUG_INFORMATION_FORMAT='dwarf-with-dsym' DWARF_DSYM_FOLDER_PATH="${dSYMPath}/${project_name}${archive_time}.dSYM" >> ${log_path}/log_build
if [ $? -eq 0 ];then
echo "====================Build Done======================="
else
echo "====================Build Failed====================="
cat ${log_path}/log_build
echo "Please check the log file in ${log_path} for detail"
exit 1
fi

#打包ipa
echo "===================Export ipa file==================="
mkdir -p ${exportPath}
if [ $? -eq 0 ];then
echo "====================Create Done======================"
else
echo "====================Create Failed===================="
echo "Please check the log file in ${log_path} for detail"
exit 1
fi
xcodebuild -exportArchive -archivePath "$archivePath" -exportOptionsPlist "$exportOptionsPlist" -exportPath "$exportPath" >> ${log_path}/log_archive
if [ $? -eq 0 ];then
echo "====================Export Done======================"
else
echo "====================Export Failed===================="
cat ${log_path}/log_archive
echo "Please check the log file in ${log_path} for detail"
exit 1
fi

#上传
echo "==============Upload to ItunesConnector=============="
${altoolPath} --validate-app -f ${ipaPath} -u ${account} -p ${password} -t ios --output-format xml >> ${log_path}/log_validate.xml
if [ $? -eq 0 ];then
echo "===================validate Done====================="
else
echo "===================validate Failed==================="
cat ${log_path}/log_validate.xml
echo "Please check the log file in ${log_path} for detail"
exit 1
fi
${altoolPath} --upload-app -f ${ipaPath} -u ${account} -p ${password} -t ios --output-format xml >> ${log_path}/log_upload.xml
if [ $? -eq 0 ];then
echo "====================upload Done======================"
else
echo "====================upload Failed===================="
cat ${log_path}/log_upload.xml
echo "Please check the log file in ${log_path} for detail"
exit 1
fi

#上传bugly
echo "=====================Bugly upload===================="
cd ${dSYMPath}
zip -r ${project_name}${archive_time}.dSYM.zip ${project_name}${archive_time}.dSYM
if [ $? -eq 0 ];then
echo "=====================zip Done========================"
rm -rf ${project_name}${archive_time}.dSYM
else
echo "====================zip Failed======================="
echo "Please check the log file in ${log_path} for detail"
exit 1
fi
curl -k "https://api.bugly.qq.com/openapi/file/upload/symbol?app_key=$BUGLY_APP_KEY&app_id=$BUGLY_APP_ID" --form "api_version=1" --form "app_id=$BUGLY_APP_ID" --form "app_key=$BUGLY_APP_KEY" --form "symbolType=2"  --form "bundleId=$bundleID" --form "productVersion=1.0" --form "channel=App-Store" --form "fileName=${project_name}${archive_time}.dSYM.zip" --form "file=@${project_name}${archive_time}.dSYM.zip" --verbose >> ${log_path}/log_bugly
if [ $? -eq 0 ];then
echo "====================upload Done======================"
else
echo "====================upload Failed===================="
cat ${log_path}/log_bugly
echo "Please check the log file in ${log_path} for detail"
exit 1
fi
echo "=======================All Done======================"
echo "Please check the log file in ${log_path} for detail"
exit 0
