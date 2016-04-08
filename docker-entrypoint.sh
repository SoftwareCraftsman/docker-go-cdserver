#!/bin/bash

if [ ! -f "/var/go/.ssh/id_rsa" ] ; then
  mkdir -p /var/go/.ssh
  ssh-keygen -C "docker-gocd" -N '' -f /var/go/.ssh/id_rsa
  chown -R go:go /var/go/.ssh
  eval "$(ssh-agent -s)"
  ssh-add /var/go/.ssh/id_rsa
fi

if [ ! -f "/etc/go/cruise-config.xml" ] ; then
  cp cruise-config.xml /etc/go/cruise-config.xml
  # Setup auto registration for agents.
  AGENT_KEY="${AGENT_KEY:-7fd926aa8323}"
  [[ -n "$AGENT_KEY" ]] && sed -i -e 's/agentAutoRegisterKey="[^"]*" *//' -e 's#\(<server\)\(.*artifactsdir.*\)#\1 agentAutoRegisterKey="'$AGENT_KEY'"\2#' /etc/go/cruise-config.xml

  [[ -n "$SERVER_ID" ]] && sed -i -e 's/serverId="[^"]*" *//' -e 's#\(<server\)\(.*artifactsdir.*\)#\1 serverId="'$SERVER_ID'"\2#' /etc/go/cruise-config.xml
fi

echo "Starting go-server with agent key $AGENT_KEY"

exec /etc/init.d/go-server start