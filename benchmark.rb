#!/usr/bin/env ruby
# Periodically starts 20 containers at once, in an attempt to trigger an IP collision. We
# detect collisions by examining the output of docker inspect.

require 'json'

def log(msg)
  puts("[#{Time.now}] #{msg}")
end

def docker(cmd)
  `docker #{cmd}`.tap { raise unless $? == 0 }
end

def running_containers
  docker('ps -q').strip.lines.map(&:strip)
end

def docker_kill(*containers)
  containers.map { |c| Thread.new { docker("kill #{c}") } }.each(&:join)
end

def docker_inspect(*containers)
  return [] if containers.count == 0

  JSON.parse(docker("inspect #{containers.join(' ')}")).map do |container|
    {
      container_id: container['Id'],
      created_at: container['Created'],
      port: container['NetworkSettings']['Ports']['8080/tcp'][0]['HostPort'],
      ip_address: container['NetworkSettings']['IPAddress'],
    }
  end
end

def docker_run(image = 'busy-spin-then-netcat')
  docker("run -P -d #{image}")
end

def container_collisions
  docker_inspect(*running_containers).
    group_by { |container| container[:ip_address] }.
    select { |ip, containers| containers.size > 1 }
end

def wait_until_healthcheck
  containers = docker_inspect(*running_containers)
  while containers.any?
    sleep 1
    log("#{containers.count} containers pending health check...")
    containers.each do |container|
      if `timeout 1 nc localhost #{container[:port]}`.strip == 'done'
        containers -= [container]
      end
    end
  end

  log("All containers health checked!")
end

batch_size = 50

until container_collisions.any?
  log("No collisions, killing running...")
  docker_kill(*running_containers)

  log("Starting new batch of #{batch_size}...")
  batch_size.times.map { Thread.new { docker_run } }.each(&:join)

  wait_until_healthcheck
end

puts(JSON.pretty_generate(container_collisions))
