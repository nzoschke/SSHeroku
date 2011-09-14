#!/bin/bash
BIN_DIR=$(cd $(dirname $0); pwd) # absolute path
ETC_DIR=$(dirname $BIN_DIR)/etc

cat <<EOF >/tmp/sshd_config
Protocol 2
Port ${PORT:-5000}
AuthorizedKeysFile $ETC_DIR/ssh/authorized_keys
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
PermitRootLogin no
LoginGraceTime 20
HostKey $ETC_DIR/ssh/ssh_host_key
UsePrivilegeSeparation no
PermitUserEnvironment yes
EOF

/usr/sbin/sshd -D -e -f /tmp/sshd_config