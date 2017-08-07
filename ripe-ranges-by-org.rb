#!/usr/bin/ruby

require 'json'
require 'net/http'
require 'netaddr'

if ARGV[0].nil?
  $stderr.puts 'Usage: <RIPE-ORG>'
  exit 1
end

ripe_org=ARGV[0] # ORG-HAA1-RIPE

uri = URI("http://rest.db.ripe.net/search?inverse-attribute=org&type-filter=inetnum&type-filter=inet6num&source=ripe&query-string=#{ripe_org}")

Net::HTTP.start('rest.db.ripe.net', 80) do |http|
  request = Net::HTTP::Get.new(uri)
  request['Accept'] = 'application/json'
  response = http.request(request)

  if response.code != '200'
    $stderr.puts 'splark'
    exit 1
  end

  content = JSON.parse(response.body)

  content['objects']['object'].each do |object|
    if object['type'] == 'inetnum'
     first_ip = object['primary-key']['attribute'][0]['value'].split(' ')[0]
     last_ip = object['primary-key']['attribute'][0]['value'].split(' ')[2]
     ip_range = NetAddr.range(first_ip, last_ip, :Inclusive => true, :Objectify => true)

     puts NetAddr.merge(ip_range, :Objectify => true)
    elsif object['type'] == 'inet6num'
      puts object['primary-key']['attribute'][0]['value']
    end
  end
  
end
