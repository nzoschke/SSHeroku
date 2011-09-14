#!/bin/bash
BIN_DIR=$(cd $(dirname $0); pwd) # absolute path
ETC_DIR=$(dirname $BIN_DIR)/etc/ssh

USER=$(whoami)
HOST=$(/sbin/ifconfig eth0  | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')
PORT=${PORT:-5000}
(while true; do
  echo ssh $USER@$HOST -p $PORT
  sleep 600
done) &

cat <<EOF >$ETC_DIR/sshd_config
AllowUsers *
Protocol 2
Port $PORT
AuthorizedKeysFile $ETC_DIR/authorized_keys
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
PermitRootLogin no
LoginGraceTime 20
HostKey $ETC_DIR/ssh_host_key
UsePrivilegeSeparation no
PermitUserEnvironment yes
EOF

/usr/sbin/sshd -D -e -f $ETC_DIR/sshd_config