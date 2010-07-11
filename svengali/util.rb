# -*- coding: utf-8 -*-
require "socket"

#module CloudUtil
class CLibIPAddr
  @ipaddr

  def initialize(ipaddr_str)
    @ipaddr = ipaddr_str
  end

  def inc!
    splited_arr = @ipaddr.split(".")
    last_octet = splited_arr[3].to_i
    #remove last octet
    splited_arr.pop()
    @ipaddr = splited_arr.join(".") + "." + (last_octet+1).to_s
  end

  def to_s
    return @ipaddr
  end

  def dup()
    return CLibIPAddr.new(@ipaddr)
  end
end

$output_debug_print = false

def stop_debug_print()
  $output_debug_print = false
end

def debug_p(str = "")
  if $output_debug_print
    puts "[DEBUG #{caller(1)[0]}] #{str}"
  end
end

def not_inp()
  debug_p(caller(1)[0] + " -> Not implemented yet.")
end

def lazy_inp()
  debug_p(caller(1)[0] + " -> Lazily implemented. Here should be fixed if you have time.")
end

def not_tested()
  debug_p(caller(1)[0] + " -> Not tested yet.")
end

def load_plugin(plugin_name_str)
  #    open( File::dirname(__FILE__) + "/plugin/" + plugin_name_str + ".rb"){ |file|
  #      contents = file.read()
  #      contents = "class Machine\n" + contents + "\nend"
  #      eval(contents)
  #    }
  require "#{LIBNAME}/plugins/" + plugin_name_str
end

# change platform "default" to *platform_name_str*
# "default" was specified on svengali.rb on ahead
def change_platform(platform_name_str)
  require "#{LIBNAME}/platforms/" + platform_name_str
  $platform_name = platform_name_str
end

def err_message_and_exit(str)
  debug_p str
  debug_p "I'm exiting!"

  exit()
end

# **Attention** this method passes nil values
def check_has_keys(params_hash,array_of_symbols)
  array_of_symbols.each{ |symbol|
    unless params_hash.has_key?(symbol)
      err_message_and_exit("please specify a value of :" + symbol.to_s() + "!")
    end
  }
end

# ipaddr -> ClibIPAddr : destination IP address
# return -> boolean
#
# This method returns at most 3sec after
def is_exist_by_ping(ipaddr)
  # this execution returns at most 3sec after
  `ping #{ipaddr.to_s} -c 1 -w 3`
  result = ( $? == 0 ) ? true : false
  return result
end

# ipaddr_range_str is like below
#            "192.168.1.100-200"
#
# return -> hash : { string of ipaddr => true, ........ , string of ipaddr => true}
def find_machines_on_range_by_ping(ipaddr_range_str)
  octets_arr = ipaddr_range_str.split(".")
  splited_last_octet = octets_arr[3].split("-")

  alive_hash = Hash.new()
  for last_octet in splited_last_octet[0].to_i .. splited_last_octet[1].to_i
    t = Thread.new do
      dest_ip_str = octets_arr[0] + "." + octets_arr[1] + "." + octets_arr[2] + "." + last_octet.to_s()
      if is_exist_by_ping(CLibIPAddr.new(dest_ip_str))
        alive_hash[dest_ip_str] = true
      end
    end
  end

  t.join

  return alive_hash
end
