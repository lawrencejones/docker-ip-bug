# Docker IP Bug

We're seeing situations where docker will assign an IP to multiple containers.
The `benchmark.rb` script should expose this bug, and will run until it sees an
occurrence.

```
$ vagrant up
$ vagrant ssh
vagrant@vagrant-ubuntu-trusty-64:~$ sudo su -
root@vagrant-ubuntu-trusty-64:~# cd /data && mkdir tmp
root@vagrant-ubuntu-trusty-64:/data# ./benchmark.rb 50 | tee -a tmp tmp/benchmark.log

[2017-05-03 17:35:38 +0000] Successfully build 757970410c34
[2017-05-03 17:35:38 +0000] No collisions, killing running...
[2017-05-03 17:35:38 +0000] Starting new batch of 50...
[2017-05-03 17:36:00 +0000] No collisions, killing running...
[2017-05-03 17:36:13 +0000] Starting new batch of 50...
[2017-05-03 17:36:35 +0000] No collisions, killing running...
[2017-05-03 17:36:48 +0000] Starting new batch of 50...
{
  "172.17.0.17": [
    {
      "container_id": "7411bbdfef58425956dbf009d8182d7fba644495c80aa172aba228839f47d467",
      "created_at": "2017-05-03T17:36:48.933263081Z",
      "port": "40884",
      "ip_address": "172.17.0.17"
    },
    {
      "container_id": "176dddd151b9607599990d5b4607d55f0f9b2d3f9963c104a390d413b9391b0e",
      "created_at": "2017-05-03T17:36:48.933102548Z",
      "port": "40888",
      "ip_address": "172.17.0.17"
    }
  ],
  "172.17.0.16": [
    {
      "container_id": "7fc5c4384ba7826ab92292bf40c4ee481b34f7913128f85f1c0041145c1fa566",
      "created_at": "2017-05-03T17:36:48.932370799Z",
      "port": "40887",
      "ip_address": "172.17.0.16"
    },
    {
      "container_id": "8ea82967e550ce076cc40802b2064942222805cfe00269629be37fdea3dc6a79",
      "created_at": "2017-05-03T17:36:48.922545985Z",
      "port": "40892",
      "ip_address": "172.17.0.16"
    }
  ]
}
```
