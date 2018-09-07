#!/bin/sh

#测试包配置文件: da07d28b-cff3-4f3b-b073-1de66d1a1ec4
#发布包配置文件:
echo "===================Archive Script===================="
echo "Author:Mist"#尊重原创者
echo "Version:1.0.0"
echo "===================Archive Script===================="

########################环境变量开始########################
#evn config
export LANG=en_US.UTF-8
#base config
#开发配置
provisioningProfile_dev="da07d28b-cff3-4f3b-b073-1de66d1a1ec4"
#开发证书
codeSignIdentity_dev="iPhone Developer: lei zhang (QYNKJGF5K9)"
#TODO: 生产配置
provisioningProfile_dis=""
#TODO: 生产证书
codeSignIdentity_dis=""
#bugly配置
#BUGLY_APP_ID="71fd58c2b6"
#BUGLY_APP_KEY="ee03cb94-7d04-4849-8876-88bb7e1d5d26"

#时间
ArchiveTime=`date +%Y%m%d%H%M%S`
#包库的路径
ArchivePackagePath="/Users/mac/.jenkins/iOS_ARCHIVE_PACKAGE"
#TODO: 配置是否为Debug, 根据入参判断, Release \ Debug
Configuration="Debug"
#TODO: archiverOpt.plist配置(根据入参配置: development / app-store)
Method=development
#签名风格
SigningStyle=manual
#一个AppleID一个teamID, 改变不了的
TeamID=5DHMHMME2V

#log是否存文档
log_archive_A=0
log_archive_B=1
########################环境变量结束########################

# ============= 获取wordSpace路径 =============
TaskWorkSpacePath=$(pwd)
echo TaskWorkSpacePath: $TaskWorkSpacePath

# ============= 判断ExportOptions.plist =============
PlistName="ExportOptions.plist"
ExportOptionsPlist="${TaskWorkSpacePath}/${PlistName}"
# 这里的-f参数判断$ExportOptionsPlist是否存在
if [ ! -f "${ExportOptionsPlist}" ]; then
/usr/libexec/PlistBuddy -c "save" ${ExportOptionsPlist}
else
echo "exist"
fi

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


# ============= 配置证书 =============
#NOTE: 工程文件夹名字必须跟工程名字一样
schemeFolder=${scheme}
#TODO: 根据参数判断, 后期通过Jenkins操作, 动态的传入参数, 现暂时mock着
BUILD_MODE=$1
#-----mock----
BUILD_MODE="Develop"
#-----mock_end----
if [ "$BUILD_MODE" = "Develop" ]
then
#测试配置
codeSignIdentity=${codeSignIdentity_dev}
appStoreProvisioningProfile=${provisioningProfile_dev}
elif [ "$BUILD_MODE" =  "Release" ]
then
#发布配置
codeSignIdentity=${codeSignIdentity_dis}
appStoreProvisioningProfile=${provisioningProfile_dis}
else
echo "please append arguement eg. Develop Release"
exit 1
fi
# ============= END =============


# ============= 创建各种PATH =============
#项目名称
ProjectName=${scheme}
#工作空间名称
WorkspaceName="${ProjectName}.xcworkspace"
#工程路径
ProjectPath="${TaskWorkSpacePath}/${schemeFolder}"
#工作空间路径
WorkspacePath="${ProjectPath}/${WorkspaceName}"
#InfoPlist路径
InfoPlistPath="${ProjectPath}/${scheme}/Info.plist"
#TODO: 这里要判断infoPlist是否存在, 现在暂时不管
BundleID=""
# ============= 获取BundleID =============
BundleID=$(/usr/libexec/PlistBuddy -c "Print CFBundleURLTypes:0:CFBundleURLSchemes:0" "${InfoPlistPath}")
# ============= END =============

# ============= 配置包文件夹PATH =============
#具体的包路径: 包库/开发或发布/bundleID/时间戳
PackagePath="${ArchivePackagePath}/${BUILD_MODE}/${BundleID}/${ArchiveTime}"
#log文件路径, 跟着每一个包
LogPath="${PackagePath}/log"
#编译路径: 跟着每一个包
ConfigurationBuildPath="${PackagePath}/build"
#archive路径: 跟着每一个包
ArchivePath="${PackagePath}/archive/${ProjectName}.xcarchive"
#dSYM文件路径: 是archive时候生成的, 跟着每一个archive
dSYMPath="${PackagePath}/archive/dSYMs/${ProjectName}.dSYM"
#生成ipa路径
ExportPath="${PackagePath}/exportPackage"
#ipa路径
ipaPath="${ExportPath}/${ProjectName}.ipa"
#拷贝到这个共享目录
ExportPackageTo="/Users/mac/iOS_ARCHIVE_PACKAGE/${BUILD_MODE}/${BundleID}/${ArchiveTime}"






#TODO: 解锁KeyChain, 听说要解锁.? 先注释试试
#security unlock-keychain -p lizhuxian020 ~/Library/Keychains/login.keychain

#配置ipa输出的plistOp
echo "=============Configure export plist file============="

/usr/libexec/PlistBuddy -c "Add :provisioningProfiles:${BundleID} string ${appStoreProvisioningProfile}" "${ExportOptionsPlist}"
if [ $? -eq 0 ]; then
echo "add provisioningProfiles success"
else
/usr/libexec/PlistBuddy -c "Set provisioningProfiles:${BundleID} ${appStoreProvisioningProfile}" "${ExportOptionsPlist}"
fi

/usr/libexec/PlistBuddy -c "Add method string ${Method}" "${ExportOptionsPlist}"
if [ $? -eq 0 ]; then
echo "add method success"
else
/usr/libexec/PlistBuddy -c "Set method ${Method}" "${ExportOptionsPlist}"
fi

/usr/libexec/PlistBuddy -c "Add :signingCertificate string ${codeSignIdentity}" "${ExportOptionsPlist}"
if [ $? -eq 0 ]; then
echo "add signingCertificate success"
else
/usr/libexec/PlistBuddy -c "Set signingCertificate ${codeSignIdentity}" "${ExportOptionsPlist}"
fi

/usr/libexec/PlistBuddy -c "Add :signingStyle string ${SigningStyle}" "${ExportOptionsPlist}"
if [ $? -eq 0 ]; then
echo "add signingStyle success"
else
/usr/libexec/PlistBuddy -c "Set signingStyle ${SigningStyle}" "${ExportOptionsPlist}"
fi

/usr/libexec/PlistBuddy -c "Add :teamID string ${TeamID}" "${ExportOptionsPlist}"
if [ $? -eq 0 ]; then
echo "add teamID success"
else
/usr/libexec/PlistBuddy -c "Set teamID ${TeamID}" "${ExportOptionsPlist}"
fi

echo "===================Configure Done===================="

#创建日志路径
echo "==============Create log file directory=============="
mkdir -p ${LogPath}
if [ $? -eq 0 ];then
echo "===================Create success===================="
echo LogPath: ${LogPath}
else
echo "===================Create Failed====================="
echo "Please check the log file in ${LogPath} for detail"
exit 1
fi

#创建导出路径
echo "==============Create ExportPackageTo=============="
mkdir -p ${ExportPackageTo}
if [ $? -eq 0 ];then
echo "===================Create success===================="
echo ExportPackageTo: ${ExportPackageTo}
else
echo "===================Create Failed====================="
echo "Please check the log file in ${ExportPackageTo} for detail"
exit 1
fi

#cocoapods
echo "==============Cocoapod install process==============="
cd ${ProjectPath}
if [ ${log_archive_A} = ${log_archive_B} ];then
pod install >> ${LogPath}/log_pods
else
pod install
fi
if [ $? -eq 0 ];then
echo "===================Cocoapod Done====================="
else
echo "===================Create Failed====================="
cat ${LogPath}/log_pods
echo "Please check the log file in ${LogPath} for detail"
exit 1
fi

#清理构建
echo "=============Cleanup previous build file============="
if [ ${log_archive_A} = ${log_archive_B} ];then
comm="xcodebuild clean -workspace ${WorkspacePath} -scheme ${scheme} -configuration ${Configuration} >> ${LogPath}/log_clean"
else
comm="xcodebuild clean -workspace ${WorkspacePath} -scheme ${scheme} -configuration ${Configuration}"
fi
echo ${comm}
eval ${comm}
if [ $? -eq 0 ];then
echo "===================Cleanup Done======================"
else
echo "===================Cleanup Failed===================="
cat ${LogPath}/log_clean
echo "Please check the log file in ${LogPath} for detail"
exit 1
fi

#TODO: 更新build, 先不更新, 有需要再说
#/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $archive_time" "${project_dir}/${project_name}/${scheme}.plist"

#编译
echo "=================Build process start================="
if [ ${log_archive_A} = ${log_archive_B} ];then
comm="xcodebuild archive -workspace ${WorkspacePath} -scheme ${scheme} -configuration ${Configuration} -archivePath ${ArchivePath} DWARF_DSYM_FOLDER_PATH=\"${dSYMPath}\" CONFIGURATION_BUILD_DIR=\"${ConfigurationBuildPath}\" CODE_SIGN_IDENTITY=\"${codeSignIdentity}\" PROVISIONING_PROFILE_SPECIFIER=\"${appStoreProvisioningProfile}\" DEBUG_INFORMATION_FORMAT=\"dwarf-with-dsym\"  >> ${LogPath}/log_build"
else
comm="xcodebuild archive -workspace ${WorkspacePath} -scheme ${scheme} -configuration ${Configuration} -archivePath ${ArchivePath} DWARF_DSYM_FOLDER_PATH=\"${dSYMPath}\" CONFIGURATION_BUILD_DIR=\"${ConfigurationBuildPath}\" CODE_SIGN_IDENTITY=\"${codeSignIdentity}\" PROVISIONING_PROFILE_SPECIFIER=\"${appStoreProvisioningProfile}\" DEBUG_INFORMATION_FORMAT=\"dwarf-with-dsym\" "
fi

echo ${comm}
eval ${comm}
if [ $? -eq 0 ];then
echo "====================Build Done======================="
else
echo "====================Build Failed====================="
cat ${LogPath}/log_build
echo "Please check the log file in ${LogPath} for detail"
exit 1
fi


#打包ipa
echo "===================Export ipa file==================="
mkdir -p ${ExportPath}
if [ $? -eq 0 ];then
echo "====================Create Done======================"
else
echo "====================Create Failed===================="
echo "Please check the log file in ${ExportPath} for detail"
exit 1
fi
if [ ${log_archive_A} = ${log_archive_B} ];then
comm="xcodebuild -exportArchive -archivePath ${ArchivePath} -exportOptionsPlist ${ExportOptionsPlist} -exportPath ${ExportPath} >> ${LogPath}/log_archive"
else
comm="xcodebuild -exportArchive -archivePath ${ArchivePath} -exportOptionsPlist ${ExportOptionsPlist} -exportPath ${ExportPath} "
fi

echo ${comm}
eval ${comm}
if [ $? -eq 0 ];then
echo "====================Export Done======================"
cp -r ${PackagePath} ${ExportPackageTo}
echo ipa_package: ${ExportPackageTo}
else
echo "====================Export Failed===================="
cat ${LogPath}/log_archive
echo "Please check the log file in ${LogPath} for detail"
exit 1
fi


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
