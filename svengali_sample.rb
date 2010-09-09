#! /bin/ruby
# -*- coding: utf-8 -*-
require "rubygems"
require "svengali"

user_name = "xxxxxxxx"
password = "xxxxxxxx"

# Use IP addres due to access by sequence number
IPADDR_BASE = CLibIPAddr.new("xxx.xxx.xxx.xxx")

MACHINE_NUM = 1
nodes = Array.new(MACHINE_NUM)

tmp_ipaddr = IPADDR_BASE.dup()
MACHINE_NUM.times{ |n|
  # FQDN machine name can be also passed
  nodes[n] = Machine.new(tmp_ipaddr)
  nodes[n].set_auth_info(user_name,password)
  # establishes a transport for command execution via sshd_conf
  nodes[n].establish_session()
  puts nodes[n].exec!("uname -v")
  # install package
  # package system used is default one ( yum )
  puts nodes[n].install_package("xxxx")
  tmp_ipaddr.inc!()
}

nodes.each{ |a_node|
  # edit configuration file
  sshd_conf = a_node.get_config_file("xxxxxxx.conf")
  sshd_conf.replace_col("xxxxxx","xxxxxx")
  sshd_conf.save()
}

# start experiment
nodes.each{ |a_node|
  # bonus
  puts a_node.exec!("uname -a")
  
  # executes experiment script_on
  puts a_node.exec_script_on("/home/xxx/xxxx.sh,"","/home/xxx")
}
