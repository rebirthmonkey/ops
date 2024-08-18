#!/usr/bin/env bash

#INSECURE_SERVER="127.0.0.1:8888"
INSECURE_SERVER="app1.tmigrate.com"
SECURE_SERVER="127.0.0.1:8443"

Header="-HContent-Type: application/json"
CCURL="curl -f -s -XPOST" # Create
UCURL="curl -f -s -XPUT" # Update
RCURL="curl -f -s -XGET" # Get
DCURL="curl -f -s -XDELETE" # Delete


insecure::hello()
{
  ${RCURL} http://${INSECURE_SERVER}/hello
}

insecure::user()
{
  ${RCURL} "http://${INSECURE_SERVER}/users"; echo  # 列出所有用户
}

insecure::group()
{
  ${RCURL} "http://${INSECURE_SERVER}/groups"; echo
}

insecure::auth()
{
  ${RCURL} "http://${INSECURE_SERVER}/auth?user=admin&pwd=P@ssw0rd"; echo
}


if [[ "$*" =~ insecure:: ]];then
  eval $*
fi
