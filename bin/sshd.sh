#!/bin/bash
BIN_DIR=$(cd $(dirname $0); pwd) # absolute path
ETC_DIR=$(dirname $BIN_DIR)/etc/ssh

USER=$(whoami)
PORT=${PORT:-5000}

touch /tmp/last
(while true; do
  echo user=$USER

  touch -d '-1 minute' /tmp/limit
  ps ax | grep sshd: && touch /tmp/last
  [ /tmp/limit -nt /tmp/last ] && { echo "1 minute exceeded"; exit 1; }
  sleep 10
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