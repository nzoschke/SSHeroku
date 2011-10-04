#!/bin/bash

BIN_DIR=$(cd $(dirname $0); pwd) # absolute path
ETC_DIR=$(dirname $BIN_DIR)/etc/ssh

PORT=${PORT:-5000}
PID_FILE=$ETC_DIR/sshd.pid

prefer() { eval "${!#}() { $(which $* | head -1) \"\$@\"; }; declare -fx ${!#};"; }
prefer gtouch touch

# Monitor sshd for connections; self-destruct if none seen for 30s
touch /tmp/seen
(while true; do
  echo user=$(whoami)

  touch -d '-30 seconds' /tmp/timeout
  ps ax | grep -v grep | grep -q sshd: && touch /tmp/seen

  [ /tmp/seen -ot /tmp/timeout ] && {
    echo "non-connect timeout exceeded";
    kill -9 $(cat $PID_FILE);
    exit 1
  }

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
PidFile $PID_FILE
EOF

/usr/sbin/sshd -D -e -f $ETC_DIR/sshd_config