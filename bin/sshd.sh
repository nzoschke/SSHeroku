#!/bin/bash
BIN_DIR=$(cd $(dirname $0); pwd) # absolute path
ETC_DIR=$(dirname $BIN_DIR)/etc/ssh

USER=$(whoami)
PORT=${PORT:-5000}

touch /tmp/last
(while true; do
  echo user=$USER
  ps ax

  touch -d '-20 seconds' /tmp/limit
  ps ax | grep sshd: | grep -v grep && touch /tmp/last
  [ /tmp/limit -nt /tmp/last ] && { echo "non-connect limit exceeded"; kill -9 12; } # magic number PID
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