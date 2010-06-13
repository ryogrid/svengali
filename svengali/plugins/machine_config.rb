class Machine

  # :ipaddr    -> CLibIPAddr : IP address which assigned to interface
  # :interface -> string     : interface name
  # :netmask   -> string     : netmask
  # :gateway   -> CLibIPAddr : IP address of gateway
  # :onboot    -> string     : yes or no (you can omit)
  # :hwaddr    -> string     : MAC address (you can omit)
  def config_nw_interface(params_hash)
    config_file = nil
    if interface_name_str = params_hash[:interface]
      #open or create target file
      target_path = ExtStr.path["network_configs"]+"ifcfg-" + interface_name_str
      config_file = self.get_config_file(target_path)
    else
      err_message_and_exit("please specify a value of :interface!")
    end

    if netmask = params_hash[:netmask]
      netmask_str = netmask.to_s()
      # remove_col_by_regexp should be used under normal condition
      config_file.remove_col_by_str("NETMASK")
      config_file.append_str("NETMASK=" + netmask_str + "\n")
    else
      err_message_and_exit("please specify a value of :netmask!")
    end

    if ipaddr = params_hash[:ipaddr]
      ipaddr_str = ipaddr.to_s()
      # remove_col_by_regexp should be used under normal condition
      config_file.remove_col_by_str("IPADDR")
      config_file.append_str("IPADDR=" + ipaddr_str + "\n")
    else
      err_message_and_exit("please specify a value of :ipaddr!")
    end

    if gateway = params_hash[:gateway]
      gateway_str = gateway.to_s()
      # remove_col_by_regexp should be used under normal condition
      config_file.remove_col_by_str("GATEWAY")
      config_file.append_str("GATEWAY=" + gateway_str + "\n")
    else
      err_message_and_exit("please specify a value of :gateway!")
    end

    if hwaddr = params_hash[:hwaddr]
      # remove_col_by_regexp should be used under normal condition
      config_file.remove_col_by_str("HWADDR")
      config_file.append_str("HWADDR=" + hwaddr + "\n")
    end

    onboot = params_hash[:onboot] || "yes" # default is "yes"
    # remove_col_by_regexp should be used under normal condition
    config_file.remove_col_by_str("ONBOOT")
    config_file.append_str("ONBOOT=" + onboot + "\n")

    config_file.remove_col_by_str("BOOTPROTO")
    config_file.append_str("BOOTRPROTO=static\n")

    config_file.save()
    lazy_inp()
  end

  # !!!!  Now, this method write resolver information    !!!!
  # !!!!  to /etc/sysconfig/network-scripts/ifcfg-ethX  !!!!
  # !!!!  due to baffling behavior of CentOS            !!!!
  # 
  # :primary_ip    -> CLibIPAddr : IP address of primary DNS
  # :secondry_ip   -> CLibIPAddr : IP address of secondly DNS
  # :search_domain -> string : domain of search directive
  #
  # :interface -> string     : interface name (for CentOS)
  def set_resolver(params_hash)
    #open or create target file
    config_file = nil
    if interface_name_str = params_hash[:interface]
      target_path = ExtStr.path["network_configs"]+"ifcfg-" + interface_name_str
      config_file = self.get_config_file(target_path)
    else
      err_message_and_exit("please specify a value of :interface!")
    end


#    target_path = ExtStr.path["resolver_config"]
#    config_file = self.get_config_file(target_path)
#
#    if search_domain = params_hash[:search_domain]
#      # remove_col_by_regexp should be used under normal condition
#      config_file.append_str("search " + search_domain + "\n")
#    end
#
#    if primary_ip = params_hash[:primary_ip]
#      primary_ip_str = primary_ip.to_s()
#      # remove_col_by_regexp should be used under normal condition
#      config_file.remove_col_by_str("nameserver")
#      config_file.append_str("nameserver " + primary_ip_str + "\n")
#    else
#      err_message_and_exit("please specify a value of :primary_ip!")
#    end
#
#    if secondly_ip = params_hash[:secondly_ip]
#      secondly_ip_str = secondly_ip.to_s()
#      # remove_col_by_regexp should be used under normal condition
#      config_file.append_str("nameserver " + secondly_ip_str + "\n")
#    end

    
    if primary_ip = params_hash[:primary_ip]
      primary_ip_str = primary_ip.to_s()
      # remove_col_by_regexp should be used under normal condition
      config_file.remove_col_by_str("PEERDNS")
      config_file.append_str("PEERDNS=yes\n")
      
      config_file.remove_col_by_str("DNS1")
      config_file.append_str("DNS1=" + primary_ip_str + "\n")
    else
      err_message_and_exit("please specify a value of :primary_ip!")
    end

    config_file.save()
    
    lazy_inp()
  end
  
end

