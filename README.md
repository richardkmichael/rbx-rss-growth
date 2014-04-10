This repo is a reproduction testcase for [rubinius/rubinius#2995](https://github.com/rubinius/rubinius/issues/2995).

You need Redis installed, these tests used Redis 2.8.7 and 2.8.8.

```
git clone git@github.com:richardkmichael/rbx-rss-growth.git
bundle
redis-server --unixsocket /tmp/redis.sock --port 0 # --daemonize yes

# If you want to watch redis publishes, then daemonize above and:
redis-cli -s /tmp/redis.sock monitor

# To repro RSS growth, start htop/top or use the watch command output by the test script.
# E.g., "watch -n 0.2 /proc/<pid>/status"
rbx rss_growth_during_redis_publish.rb -n 1000000

# To repro the GC tuning crash.
rbx -Xgc.immix.concurrent=false rss_growth_during_redis_publish.rb -n 1000000
```

Included is one core dump, `core/core.15380.bz2` from:

```
$ uname -a
Linux anvil.localdomain 3.13.6-200.fc20.x86_64 #1 SMP Fri Mar 7 17:02:28 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux

$ rbx --version
rubinius 2.2.6.n94 (2.1.0 249f92b1 2014-04-04 JI) [x86_64-linux-gnu]
```
