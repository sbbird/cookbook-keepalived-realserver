cookbook-keepalived-realserver
==============================
<H1>Introduction</H1>
This coobook can be used to configure real servers for [Keepalived](http://www.keepalived.org/). 
<H1>Usage</H1>
1. Add depends in ```metadata.rb```
```ruby
depends          'mon-lvs-realserver', '= 1.0.0'
```
2. Use the definition ```config_rs``` in other cookbooks, where you want to set some virtual IPs for some specific applications. 

```ruby 
config_rs "name_of_your_service" do
    vip_and_netif ({virtual_paddress => 'lo:0'})
    vip_configs [{'vip' => virtual_paddress, 'vport'=>virtual_port1, 'rport'=>real_port1,'weight'=>'100'},
                {'vip' => virtual_paddress, 'vport'=>virtual_port2, 'rport'=>real_port2,'weight'=>'100'}                
                ]
end
```
3. Append this cookbook into run_list. It will generate ```/usr/local/sbin/viprs```.

4. Run the default recipe of cookbook [cookbook-keepalived-director](https://github.com/sbbird/cookbook-keepalived-director) on the directors. 
