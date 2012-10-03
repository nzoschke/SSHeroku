SSHeroku
========

An idle but easily wake-able temporary sshd process on Heroku.

Quickstart
----------

```bash
heroku create
APP=$(heroku info | head -1 | cut -d" " -f2-2)
heroku config:add             \
  HEROKU_APP=$APP             \
  HEROKU_PASSWORD=<api_key>   \
  HEROKU_USER=<username>  \
  AUTHORIZED_KEYS="ssh-rsa AAAAB..."
git push heroku master

ssh $(curl -s $APP.herokuapp.com) uname -a
Linux 9e889cba-a41b-4497-b9bd-e394470714aa 2.6.32-316-ec2 31-Ubuntu SMP Wed May 18 14:10:36 UTC 2011 x86_64 GNU/Linux

ssh $(curl -s $APP.herokuapp.com) # gives an interactive shell!
```

Background
----------

SSHeroku is achieved with the TCP router and the OpenSSH SSH daemon.

A simple Rack app uses the Heroku `ps`, `route`, and `log` APIs to create an `sshd` process, create and attach a TCP route to it, and read the unix username from the process logs. This is returned as an SSH connection string to the client for passing to the `ssh` command.

The entire system is set to self-destruct when not used. The web app is a single idling dyno, and the sshd process will exit when it has no connections. This keeps dyno-hour usage to an absolute minimum.

Why?
----

This tool allows a true bi-directional pipeline into a Heroku dyno. Example:

```bash
tar -c . | ssh $(curl -s $APP.herokuapp.com) tar -xv
./
./.git/
...
```

Extra
-----
SSH public keys can also be checked into the `etc/ssh/authorized_keys` file.

Tail the app logs to understand what's happening. Logplex is used a channel to communicate between the ssh process and the web process.
