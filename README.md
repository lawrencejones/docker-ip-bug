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
      "name": "/small_davinci7",
      "created_at": "2017-05-03T17:36:48.933263081Z",
      "port": "40884",
      "ip_address": "172.17.0.17"
    },
    {
      "container_id": "176dddd151b9607599990d5b4607d55f0f9b2d3f9963c104a390d413b9391b0e",
      "name": "/trusting_davinci",
      "created_at": "2017-05-03T17:36:48.933102548Z",
      "port": "40888",
      "ip_address": "172.17.0.17"
    }
  ],
  "172.17.0.16": [
    {
      "container_id": "7fc5c4384ba7826ab92292bf40c4ee481b34f7913128f85f1c0041145c1fa566",
      "name": "/cranky_shockley0",
      "created_at": "2017-05-03T17:36:48.932370799Z",
      "port": "40887",
      "ip_address": "172.17.0.16"
    },
    {
      "container_id": "8ea82967e550ce076cc40802b2064942222805cfe00269629be37fdea3dc6a79",
      "name": "/prickly_spence",
      "created_at": "2017-05-03T17:36:48.922545985Z",
      "port": "40892",
      "ip_address": "172.17.0.16"
    }
  ]
}
```

## Docker logs

What we see in the logs are racing requests for addresses, which cause multiple
containers to receive the same address. With debug logging, we see:

```
root@vagrant-ubuntu-trusty-64:/var/log/upstart# grep '2017-05-03T17:36' /var/log/upstart/docker.log
time="2017-05-03T17:36:40.406182314Z" level=debug msg="ReleaseAddress(LocalDefault/172.17.0.0/16, 172.17.0.16)"
time="2017-05-03T17:36:40.564513449Z" level=debug msg="ReleaseAddress(LocalDefault/172.17.0.0/16, 172.17.0.17)"
time="2017-05-03T17:36:53.225655932Z" level=debug msg="Assigning addresses for endpoint cranky_shockley0's interface on network bridge"
time="2017-05-03T17:36:53.230230667Z" level=debug msg="Assigning addresses for endpoint prickly_spence's interface on network bridge"
time="2017-05-03T17:36:53.230297294Z" level=debug msg="Assigning addresses for endpoint trusting_davinci's interface on network bridge"
time="2017-05-03T17:36:53.230449113Z" level=debug msg="Assigning addresses for endpoint small_davinci7's interface on network bridge"
time="2017-05-03T17:36:55.977897343Z" level=debug msg="Assigning addresses for endpoint cranky_shockley0's interface on network bridge"
time="2017-05-03T17:36:56.118899633Z" level=debug msg="Assigning addresses for endpoint prickly_spence's interface on network bridge"
time="2017-05-03T17:36:56.203361531Z" level=debug msg="Assigning addresses for endpoint small_davinci7's interface on network bridge"
time="2017-05-03T17:36:56.295963372Z" level=debug msg="Assigning addresses for endpoint trusting_davinci's interface on network bridge"
time="2017-05-03T17:37:00.010042599Z" level=debug msg="Programming external connectivity on endpoint small_davinci7 (85d1e002ac98503343037a29d7947c6b5386ca48e422f6763bda171a1a1f7241)"
time="2017-05-03T17:37:00.385010449Z" level=debug msg="Programming external connectivity on endpoint cranky_shockley0 (0697a4b94b2ef40bf95cb81e9c172be918a18a21f49ab27ff40a76135589ef58)"
time="2017-05-03T17:37:00.418262126Z" level=debug msg="Programming external connectivity on endpoint trusting_davinci (6c0aa2f8475fc126354135088919cab2af0d5116def108287140197f7959ec5f)"
time="2017-05-03T17:37:00.676598484Z" level=debug msg="Programming external connectivity on endpoint prickly_spence (5203a868543bd417a8ae0701f3988c37b177681638f9012fa9cc00ed23ad8036)"
```
