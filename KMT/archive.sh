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
#TODO: bundleID配置(多个项目, 不同的bundleID?, 如何获取.?) ---change
bundleID="com.kmt518.KMTDeparture"
#bugly配置
#BUGLY_APP_ID="71fd58c2b6"
#BUGLY_APP_KEY="ee03cb94-7d04-4849-8876-88bb7e1d5d26"
#根据参数判断
BUILD_MODE=$1
#-----mock----
BUILD_MODE="Develop"
echo BUILD_MODE : ${BUILD_MODE}
#-----mock_end----
if [ "$BUILD_MODE" = "Develop" ]
then
#TODO: scheme名称(不同的项目, 不同的scheme, 如何获取.?) ---change
scheme="KMDeparture"
#测试配置
codeSignIdentity=${codeSignIdentity_dev}
appStoreProvisioningProfile=${provisioningProfile_dev}
#TODO: 这个是项目文件夹, (需要装着podfile的), 下面要用来pod install ---change
schemeFolder="KMDeparture"
#ICON_MODE="_Test"
#VERSIONSTRING="Beta"
elif [ "$BUILD_MODE" =  "Release" ]
then
#scheme名称 ---change
scheme="KMDeparture"
#发布配置
codeSignIdentity=${codeSignIdentity_dis}
appStoreProvisioningProfile=${provisioningProfile_dis}
# ---change
schemeFolder="KMDeparture"
#ICON_MODE="_PreRelease"
#VERSIONSTRING="RC"
else
echo "please append arguement eg. Develop Release"
exit 1
fi

echo codeSignIdentity: ${codeSignIdentity}
echo appStoreProvisioningProfile: ${appStoreProvisioningProfile}
#时间
archive_time=`date +%Y%m%d%H%M%S`
#TODO: 项目名称, 截取项目名称 ---change
project_name=KMDeparture
#TODO: 工作空间名称, 也是截取, 拼接 ---change
workspaceName="KMDeparture.xcworkspace"


#TODO: 项目路径, 本地路径, 获取SVN下的项目
project_dir="/Users/mac/KMTProject/${schemeFolder}"
#工作空间路径
workspace_dir="${project_dir}/${workspaceName}"
#包库的路径
autoPackageLipo_dir="/Users/mac/Desktop/AutoPackageLipo"
#具体的包路径: 包库/开发或发布/bundleID/时间戳
package_dir="${autoPackageLipo_dir}/${BUILD_MODE}/${bundleID}/${archive_time}"
#临时路径
temp_dir="${project_dir}/build/${project_name}.build/Debug/${project_name}.build"
#log文件基路径, 跟着每一个包
log_path="${package_dir}/log"
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
#log是否存文档
log_archive_A=0
log_archive_B=1
########################环境变量结束########################

#TODO: 解锁KeyChain, 听说要解锁.? 先注释试试
security unlock-keychain -p lizhuxian020 ~/Library/Keychains/login.keychain

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
echo log_path: ${log_path}
else
echo "===================Create Failed====================="
echo "Please check the log file in ${log_path} for detail"
exit 1
fi

##cocoapods
#echo "==============Cocoapod install process==============="
#cd ${project_dir}
#if [ ${log_archive_A} = ${log_archive_B} ];then
#pod install >> ${log_path}/log_pods
#else
#pod install
#fi
#if [ $? -eq 0 ];then
#echo "===================Cocoapod Done====================="
#else
#echo "===================Create Failed====================="
#cat ${log_path}/log_pods
#echo "Please check the log file in ${log_path} for detail"
#exit 1
#fi
#
##清理构建
#echo "=============Cleanup previous build file============="
##rm -rf ./build
##xcodebuild clean -configuration "$configuration" -alltargets >> ${log_path}/log_clean
##xcodebuild clean -workspace ${workspaceName} -scheme ${scheme} -configuration ${configuration} -alltargets >> ${log_path}/log_clean
#if [ ${log_archive_A} = ${log_archive_B} ];then
#comm="xcodebuild clean -workspace ${workspace_dir} -scheme ${scheme} -configuration ${configuration} >> ${log_path}/log_clean"
#else
#comm="xcodebuild clean -workspace ${workspace_dir} -scheme ${scheme} -configuration ${configuration}"
#fi
#echo ${comm}
#eval ${comm}
#if [ $? -eq 0 ];then
#echo "===================Cleanup Done======================"
#else
#echo "===================Cleanup Failed===================="
#cat ${log_path}/log_clean
#echo "Please check the log file in ${log_path} for detail"
#exit 1
#fi

#TODO: 更新build, 先不更新, 有需要再说
#/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $archive_time" "${project_dir}/${project_name}/${scheme}.plist"

#编译
echo "=================Build process start================="
#xcodebuild archive -workspace "$workspaceName" -scheme "$scheme" -configuration "$configuration" -archivePath "$archivePath" CONFIGURATION_BUILD_DIR="$configurationBuildDir" CODE_SIGN_IDENTITY="$codeSignIdentity" PROVISIONING_PROFILE_SPECIFIER="$appStoreProvisioningProfile" DEBUG_INFORMATION_FORMAT='dwarf-with-dsym' DWARF_DSYM_FOLDER_PATH="${dSYMPath}/${project_name}${archive_time}.dSYM" >> ${log_path}/log_build
if [ ${log_archive_A} = ${log_archive_B} ];then
comm="xcodebuild archive -workspace ${workspace_dir} -scheme ${scheme} -configuration ${configuration} -archivePath ${archivePath} DWARF_DSYM_FOLDER_PATH=\"${dSYMPath}\" CONFIGURATION_BUILD_DIR=\"${configurationBuildDir}\" CODE_SIGN_IDENTITY=\"${codeSignIdentity}\" PROVISIONING_PROFILE_SPECIFIER=\"${appStoreProvisioningProfile}\" DEBUG_INFORMATION_FORMAT=\"dwarf-with-dsym\"  >> ${log_path}/log_build"
else
comm="xcodebuild archive -workspace ${workspace_dir} -scheme ${scheme} -configuration ${configuration} -archivePath ${archivePath} DWARF_DSYM_FOLDER_PATH=\"${dSYMPath}\" CONFIGURATION_BUILD_DIR=\"${configurationBuildDir}\" CODE_SIGN_IDENTITY=\"${codeSignIdentity}\" PROVISIONING_PROFILE_SPECIFIER=\"${appStoreProvisioningProfile}\" DEBUG_INFORMATION_FORMAT=\"dwarf-with-dsym\" "
fi

echo ${comm}
eval ${comm}
if [ $? -eq 0 ];then
echo "====================Build Done======================="
else
echo "====================Build Failed====================="
cat ${log_path}/log_build
echo "Please check the log file in ${log_path} for detail"
exit 1
fi


##打包ipa
#echo "===================Export ipa file==================="
#mkdir -p ${exportPath}
#if [ $? -eq 0 ];then
#echo "====================Create Done======================"
#else
#echo "====================Create Failed===================="
#echo "Please check the log file in ${exportPath} for detail"
#exit 1
#fi
##xcodebuild -exportArchive -archivePath "$archivePath" -exportOptionsPlist "$exportOptionsPlist" -exportPath "$exportPath" >> ${log_path}/log_archive
#if [ ${log_archive_A} = ${log_archive_B} ];then
#comm="xcodebuild -exportArchive -archivePath ${archivePath} -exportOptionsPlist ${exportOptionsPlist} -exportPath ${exportPath} >> ${log_path}/log_archive"
#else
#comm="xcodebuild -exportArchive -archivePath ${archivePath} -exportOptionsPlist ${exportOptionsPlist} -exportPath ${exportPath} "
#fi
#
#echo ${comm}
#eval ${comm}
#if [ $? -eq 0 ];then
#echo "====================Export Done======================"
#echo ipa_package: ${exportPath}
#else
#echo "====================Export Failed===================="
#cat ${log_path}/log_archive
#echo "Please check the log file in ${log_path} for detail"
#exit 1
#fi


#上传
#echo "==============Upload to ItunesConnector=============="
#${altoolPath} --validate-app -f ${ipaPath} -u ${account} -p ${password} -t ios --output-format xml >> ${log_path}/log_validate.xml
#if [ $? -eq 0 ];then
#echo "===================validate Done====================="
#else
#echo "===================validate Failed==================="
#cat ${log_path}/log_validate.xml
#echo "Please check the log file in ${log_path} for detail"
#exit 1
#fi
#${altoolPath} --upload-app -f ${ipaPath} -u ${account} -p ${password} -t ios --output-format xml >> ${log_path}/log_upload.xml
#if [ $? -eq 0 ];then
#echo "====================upload Done======================"
#else
#echo "====================upload Failed===================="
#cat ${log_path}/log_upload.xml
#echo "Please check the log file in ${log_path} for detail"
#exit 1
#fi
#
##上传bugly
#echo "=====================Bugly upload===================="
#cd ${dSYMPath}
#zip -r ${project_name}${archive_time}.dSYM.zip ${project_name}${archive_time}.dSYM
#if [ $? -eq 0 ];then
#echo "=====================zip Done========================"
#rm -rf ${project_name}${archive_time}.dSYM
#else
#echo "====================zip Failed======================="
#echo "Please check the log file in ${log_path} for detail"
#exit 1
#fi
#curl -k "https://api.bugly.qq.com/openapi/file/upload/symbol?app_key=$BUGLY_APP_KEY&app_id=$BUGLY_APP_ID" --form "api_version=1" --form "app_id=$BUGLY_APP_ID" --form "app_key=$BUGLY_APP_KEY" --form "symbolType=2"  --form "bundleId=$bundleID" --form "productVersion=1.0" --form "channel=App-Store" --form "fileName=${project_name}${archive_time}.dSYM.zip" --form "file=@${project_name}${archive_time}.dSYM.zip" --verbose >> ${log_path}/log_bugly
#if [ $? -eq 0 ];then
#echo "====================upload Done======================"
#else
#echo "====================upload Failed===================="
#cat ${log_path}/log_bugly
#echo "Please check the log file in ${log_path} for detail"
#exit 1
#fi
#echo "=======================All Done======================"
#echo "Please check the log file in ${log_path} for detail"
#exit 0
