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
      name: container['Name'],
      created_at: container['Created'],
      port: container['NetworkSettings']['Ports']['8080/tcp'][0]['HostPort'],
      ip_address: container['NetworkSettings']['IPAddress'],
    }
  end
end

def docker_build(tag = 'busy-spin-then-netcat')
  build_tag = docker("build -t #{tag} .").match(/Successfully built (\w+)/)[1]
  raise 'failed build' unless build_tag
  build_tag
end

def docker_run(image = 'busy-spin-then-netcat')
  docker("run -P -d #{image}")
end

def container_collisions
  docker_inspect(*running_containers).
    group_by { |container| container[:ip_address] }.
    select { |ip, containers| containers.size > 1 }
end

batch_size = ARGV.first.to_i
log("Successfully build #{docker_build}")

until container_collisions.any?
  log("No collisions, killing running...")
  docker_kill(*running_containers)

  log("Starting new batch of #{batch_size}...")
  batch_size.times.map { Thread.new { docker_run } }.each(&:join)
end

puts(JSON.pretty_generate(container_collisions))
