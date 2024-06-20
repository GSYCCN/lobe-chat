#!/usr/bin/env bash

# 函数：检查并清理URL
cleanUrl() {
  local url=\$1
  # 去除 https:// 前缀
  url=${url#https://}
  url=${url#http://}
  # 去除 .com 后缀
  url=${url%.com}
  echo $url
}

makeSedCommands() {
  printenv | \
      grep '^NEXT_PUBLIC' | \
      sed -r "s/=/ /g" | \
      while read key value; do
        if [[ "$key" == "NEXT_PUBLIC_S3_DOMAIN" ]]; then
          # 清理特定的 NEXT_PUBLIC_AHC 环境变量
          value=$(cleanUrl $value)
        fi

        # 生成 sed 替换命令
        echo "sed -i \"s#APP_$key#$value#g\""
      done
}

# Set the delimiter to newlines (needed for looping over the function output)
IFS=$'\n'
# For each sed command
for c in $(makeSedCommands); do
  # For each file in the .next directory
  for f in $(find .next -type f); do
    # Execute the command against the file
    COMMAND="$c $f"
    eval $COMMAND
  done
done

echo "Starting Nextjs"
# Run any arguments passed to this script
exec "$@"
