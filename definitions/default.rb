define :config_rs do

    def start_viprs
        execute 'viprs_start' do
            command '/usr/local/sbin/viprs start'
        end
    end

    ## replace duplicated or illegal network interface
    def check_netif_syntax_of vip_and_netif
        known_vn = {}
        known_netifs = []
        node['lvs-real-server']['service'].values.each do |n|
            known_netifs += n['vip_and_netif'].values
            known_vn = known_vn.merge n['vip_and_netif']
        end

        Hash[
             vip_and_netif.map do |vip, netif|
                 if not known_vn[vip].nil?
                     Chef::Log.warn "#{vip} already defined with netif #{known_vn[vip]}. Use that settings"
                     [vip, known_vn[vip]]

                 elsif netif !~ /^lo:/ or known_netifs.include? netif
                     new_netif = gen_new_netif_with known_netifs
                     Chef::Log.warn "Network interface: #{netif} - not started with 'lo:' or already exists, Automatically replaced to #{new_netif}"
                     known_netifs << new_netif
                     [vip, new_netif]

                 else
                     known_netifs << netif
                     [vip, netif]

                 end
             end
            ]
    end

    def gen_new_netif_with (existed_network_interfaces)
        (0..255).each do |postfix|
            new_netif = "lo:#{postfix}"
            return new_netif unless existed_network_interfaces.include? new_netif
        end
        raise "Generating new newif failed with interface_list #{existed_network_interfaces}"
    end

    ## Check if all necessary configure items have been well defined
    def check_vip_config_with (vip_configs, vips)

        config_keys = ['vip','vport','rport','weight']
        vips_in_config = []

        vip_configs.each do |config|
            config_keys.each do |key|
                raise "#{key} not defined in #{config}" if config[key].nil?
            end
            vips_in_config << config['vip']
        end

        ## check if vips is the subset of vips_in_config
        raise "All vips should be included in vip_confgs" unless (vips - vips_in_config).empty?

        vip_configs
    end

    r = params

    node.default['lvs-real-server'] ||= {}
    node.default['lvs-real-server']['service'] ||= {}

    raise "Name: #{r[:name]} already has been used. Change to another name." if node['lvs-real-server']['service'].keys.include? r[:name]

    vips = r[:vip_and_netif].keys.to_set
    vip_and_netif = check_netif_syntax_of r[:vip_and_netif]
    vip_configs = check_vip_config_with(r[:vip_configs], vips)
    node.default['lvs-real-server']['service'][r[:name]]['vips'] = vips.to_a
    node.default['lvs-real-server']['service'][r[:name]]['vip_and_netif'] = vip_and_netif
    node.default['lvs-real-server']['service'][r[:name]]['vip_configs'] = vip_configs

end
