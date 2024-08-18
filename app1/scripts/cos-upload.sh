#!/bin/bash

pip3 install coscmd

# 要上传的本地文件路径
local_file="_output/platforms/linux/amd64/app1"
local_conf="configs/config.yaml"

# 存储桶名称和区域
bucket_name="tmigrate-1308273016"

# 目标 COS 路径（例如: folder/on/cos/goapp）
cos_path="tmigrate/app1"

# 配置 COSCMD
coscmd config -a $TENCENTCLOUD_SECRET_ID -s $TENCENTCLOUD_SECRET_KEY -b $bucket_name -r $TENCENTCLOUD_REGION


# 上传文件到 COS
coscmd upload $local_file $cos_path/app1
coscmd upload $local_conf $cos_path/config.yaml

echo "Upload completed!"
