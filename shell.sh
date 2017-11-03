#使用方法
# .bash_profile
if [ ! -d ./IPADir ];
then
mkdir -p IPADir;
fi

#工程绝对路径
project_path=$(cd `dirname $0`; pwd)

#工程名 将XXX替换成自己的工程名
project_name=XXX

#scheme名 将XXX替换成自己的sheme名
scheme_name=XXX

#打包模式 Debug/Release
development_mode=Debug

#build文件夹路径
build_path=${project_path}/build

#plist文件所在路径
exportOptionsPlistPath=${project_path}/exportTest.plist

#导出.ipa文件所在路径
exportIpaPath=${project_path}/IPADir/${development_mode}

development_mode=Debug
exportOptionsPlistPath=${project_path}/exportTest.plist

echo '///-----------'
echo '/// 正在清理工程'
echo '///-----------'
echo '/// 工程路径:'${project_path}
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit


echo '///--------'
echo '/// 清理完成'
echo '///--------'
echo ''

echo '///-----------'
echo '/// 正在编译工程:'${development_mode}
echo '///-----------'
xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive -quiet  || exit
#CODE_SIGN_IDENTITY="${MY_CODE_SIGN_IDENTIT}" PROVISIONING_PROFILE_SPECIFIER="${MY_PROVISIONING_PROFILE_SPECIFIER}"
echo '///--------'
echo '/// 编译完成'
echo '///--------'
echo ''

echo '///----------'
echo '/// 开始ipa打包'
echo '///----------'
xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

if [ -e $exportIpaPath/$scheme_name.ipa ];
then
echo '///----------'
echo '/// ipa包已导出'
echo '///----------'
open $exportIpaPath
else
echo '///-------------'
echo '/// ipa包导出失败 '
echo '///-------------'
fi
echo '///------------'
echo '/// 打包ipa完成  '
echo '///-----------='
echo ''

echo '///-------------'
echo '/// 开始发布ipa包 '
echo '///-------------'


#上传到Fir
# 将XXX替换成自己的Fir平台的token
#fir login -T 10a1f1ed46f3e1869d8444d66351ac45
#fir publish $exportIpaPath/$scheme_name.ipa

echo "开始上传到蒲公英"
#上传到蒲公英
#蒲公英aipKey
MY_PGY_API_K=XXXXXXXXXXXXX
#蒲公英uKey
MY_PGY_UK=XXXXXXXXXXXXXXXXX

curl -F "file=@${exportIpaPath}/${scheme_name}.ipa" -F "uKey=${MY_PGY_UK}" -F "_api_key=${MY_PGY_API_K}" https://qiniu-storage.pgyer.com/apiv1/app/upload

echo "\n\n"
echo "已运行完毕>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"


appInfoPlistPath="`pwd`/XXX/Info.plist"
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${appInfoPlistPath})
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${appInfoPlistPath})
echo '///-------------'
echo '/// 邮件发送中。。。。。。。。 '
echo '///-------------'


#上传到蒲公英 发送邮件
python sendEmail.py "测试版本 iOS ${bundleShortVersion}(${bundleVersion})上传成功" "赶紧下载体验吧!https://www.pgyer.com/XXX"

exit 0






