case
node["platform_family"]

when "debian"  
  
  firewall_rule 'tf2-server-src1' do
    protocol :udp
    port_range 2700..27030
    direction :in
    action  :allow
    # notifies :enables, 'firewall[ufw]'
    end

  firewall_rule 'tf2-server-src2' do
    protocol :udp
    port 4380
    direction :in
    action :allow
    # notifies :enables, 'firewall[ufw]'  
  end

  firewall_rule 'tf2-server-dst1' do
    protocol :udp
    port_range 1025..65355
    direction :out
    action  :allow
    # notifies :enables, 'firewall[ufw]'
  end

end
