#!/usr/bin/env bash

if [ "$1" = "development" ]; then
  BOT_PATH=$BOT_PATH_DBG
  BOTSERVER_PATH=$BOTSERVER_PATH_DBG
  RVM_WRAPPER=$RVM_WRAPPER_DBG
  SERVICE_NAME=$SERVICE_NAME_DBG
elif [ "$1" != "development" ]; then
  echo "Invalid argument"
  exit 2
fi

commands=(
  "cd $BOT_PATH; git pull"
  "cd $BOTSERVER_PATH; $RVM_WRAPPER/bundle install --without test;"
  "cd $BOTSERVER_PATH; $RVM_WRAPPER/bundle update"
  "cd $BOTSERVER_PATH; $RVM_WRAPPER/rake snd:db:migrate"
  "sudo service $SERVICE_NAME restart"
)

for cmd in "${commands[@]}"; do
  echo "$cmd"
  ssh $DEPLOY_USER@$DEPLOY_SERVER "$cmd"
done
