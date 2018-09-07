
#!/bin/sh

ExportOptionsPlist="/Users/mac/.jenkins/workspace/ExportOptions.plist"

# 这里的-f参数判断$myFile是否存在
if [ ! -f "${ExportOptionsPlist}" ]; then
touch "${ExportOptionsPlist}"
else
echo "exist"
fi