#
# Cookbook Name:: mon-lvs-realserver
# Recipe:: default
#
# Copyright 2014, Rakuten Inc.
#
# All rights reserved - Do Not Redistribute
#

require 'set'

if not node['lvs-real-server'].nil?

    Chef::Log.warn "No service defined in node['lvs-real-server']['service'], do nothing. Please call config_rs definition before running this recipe." if node['lvs-real-server']['service'].values.nil?
    vip_and_netif = {}
    vip_configs = []
    config_keys = ['vip','vport','rport','weight']
    node['lvs-real-server']['service'].values.each do |config|
        vip_and_netif = vip_and_netif.merge config['vip_and_netif'] do |key, v1, v2|
            if !h1[key].nil? and !h2[key].nil? and h1[key] != h2[key]
                Chef::Log.warn "Network interface should be the same of vip #{key}: #{h1[key]} #{h2[key]} "
                Chef::Log.warn "Use the setting of previous one"
            end
            v1
        end
        vip_configs += config['vip_configs']
    end

    template "/usr/local/sbin/viprs" do
        source 'viprs.sh.erb'
        variables({
                   :vip_and_netif => vip_and_netif,
                   :vip_configs => vip_configs,
                  })
        mode '0755'
    end

    tag('lvs-real-server')
end
