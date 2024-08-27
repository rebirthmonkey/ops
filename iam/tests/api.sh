#!/usr/bin/env bash

INSECURE_SERVER="127.0.0.1:8888"
#INSECURE_SERVER="iam.tmigrate.com"
#SECURE_SERVER="127.0.0.1:8443"

Header="-HContent-Type: application/json"
CCURL="curl -f -s -XPOST" # Create
UCURL="curl -f -s -XPUT" # Update
RCURL="curl -f -s -XGET" # Get
DCURL="curl -f -s -XDELETE" # Delete


Token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJyZWJpcnRobW9ua2V5IiwiZXhwIjoxNzI1MDIyMjI0LCJ1c2VybmFtZSI6InRlc3QwMCJ9.VeO8PwuPW1xIWWHsowKFDFd2ESiX41eD8kj0LB2GLJk"

insecure::hello()
{
  ${RCURL} http://${INSECURE_SERVER}/
  ${RCURL} http://${INSECURE_SERVER}/ping
}

insecure::user()
{
  # 删除 test00 用户
  ${DCURL} http://${INSECURE_SERVER}/v1/users/test00; echo

  # 创建 test00
  ${CCURL} "${Header}" http://${INSECURE_SERVER}/v1/users \
    -d'{"name":"test00","password":"test00@2024","nickname":"00","email":"test00@gmail.com","phone":"1306280xxxx"}'; echo

  # 列出所有用户
  ${RCURL} "http://${INSECURE_SERVER}/v1/users"; echo

  # 获取 test00 用户的详细信息
  ${RCURL} http://${INSECURE_SERVER}/v1/users/test00; echo

  # 修改 test00 用户
  ${UCURL} "${Header}" http://${INSECURE_SERVER}/v1/users/test00 \
    -d'{"nickname":"test00_modified","email":"test00_modified@foxmail.com","phone":"1306280xxxx"}'; echo
}


insecure::auth()
{
  ${RCURL} "http://${INSECURE_SERVER}/auth?user=test00&pwd=test00@2024"; echo
}

secure::user()
{
  # 删除 test00 用户
  ${DCURL} http://${INSECURE_SERVER}/v1/users/test00 \
        -H "Authorization:${Token}" ; echo

  # 创建 test00
  ${CCURL} "${Header}" http://${INSECURE_SERVER}/v1/users \
    -H "Authorization:${Token}" \
    -d'{"name":"test00","password":"test00@2024","nickname":"00","email":"test00@gmail.com","phone":"1306280xxxx"}'; echo

  # 列出所有用户
  ${RCURL} "http://${INSECURE_SERVER}/v1/users" \
    -H "Authorization:${Token}" ; echo

  # 获取 test00 用户的详细信息
  ${RCURL} http://${INSECURE_SERVER}/v1/users/test00 \
    -H "Authorization:${Token}" ; echo

  # 修改 test00 用户
  ${UCURL} "${Header}" http://${INSECURE_SERVER}/v1/users/test00 \
    -d'{"nickname":"test00_modified","email":"test00_modified@foxmail.com","phone":"1306280xxxx"}' \
    -H "Authorization:${Token}" ; echo
}


if [[ "$*" =~ insecure:: ]];then
  eval $*
fi

if [[ "$*" =~ secure:: ]];then
  eval $*
fi