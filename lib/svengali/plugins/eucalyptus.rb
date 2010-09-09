require 'timeout'
require "yaml"

# return -> symbol : one of values below
#                       :running, :pending, :shutdown, :terminated
def get_instance_state(instance_id_str)
  exec_result = ""
  while exec_result == ""
    exec_result = `euca-describe-instances #{instance_id_str}`
  end
  
  if exec_result.index("pending")
    return :pending
  elsif exec_result.index("running")
    return :running
  elsif exec_result.index("shutting-down")
    return :shutdown
  elsif exec_result.index("terminated")
    return :terminated
  end
end

# return -> string: id of running instance
# this function..
#               blocks until kicked image starts running
#               uses c1.medium machine spec
def run_image(image_id_str)
  begin
    debug_p "trying kick instance from image #{image_id_str}"
    instance_id = `euca-run-instances #{image_id_str} -t c1.medium`.scan(/\s+(i-\w+)\s+/)[0].to_s
  rescue
    debug_p "retry!"
    retry
  end

  # waits until instance finishes booting
  while(get_instance_state(instance_id) != :running)
  end

  debug_p "instance( #{instance_id} ) has been running successfully."

  return instance_id
end

# this method blocks until the instance finishs terminating
def terminate_instance(instance_id_str)
  `euca-terminate-instances #{instance_id_str}`

  while(get_instance_state(instance_id_str) != :terminated)
  end

  debug_p "instance( #{instance_id_str} ) has been terminated successfully."
end

# this method blocks until the instance finishs terminating
def terminate_instance_all()
  instance_id_arr = get_all_instance_id()

  instance_id_arr.each{ |instance_id|
    terminate_instance(instance_id)
  }
end

# return -> array : like this
#                  ["i-xxxx","i-xxxx","i-xxxx",...]
def get_all_instance_id()
  ret_arr = `euca-describe-instances`.scan(/\s+(i-\w+)\s+/)
  debug_p ret_arr.inspect()
  return ret_arr
end

# return -> string: image id
# when timeout, returns nil
def upload_and_register_image(image_path_str,timeout_sec = nil)
  `euca-bundle-image -i #{image_path_str}`
  dir_name = File::dirname(image_path_str)
  if(dir_name == ".")
    bucket_and_image_name = image_path_str.gsub("./","")
  else
    bucket_and_image_name = image_path_str.gsub(dir_name,"")
  end

  begin
    timeout(timeout_sec) do
      `euca-upload-bundle -b #{bucket_and_image_name} -m /tmp/#{bucket_and_image_name}.manifest.xml`
    end
  rescue TimeoutError
    "Too long time elapsed to upload image file. It is highly possible that uploading is missed"
    return nil
  end

  begin
    image_id = `euca-register #{bucket_and_image_name}/#{bucket_and_image_name}.manifest.xml`.scan(/IMAGE\s+(emi\-\w+)\s*/)[0].to_s
  rescue
    debug_p "retry!"
    retry
  end
  
  `rm -f /tmp/#{bucket_and_image_name}*`

  debug_p "uploaded and registerd #{image_path_str}"
  return image_id
end

# deregister specified image and delete images on server
def delete_image(image_id_str)
  `euca-deregister #{image_id_str}`
  bucket_and_image = get_bucket_and_image_name_by_id(image_id_str)

  `euca-delete-bundle -b #{bucket_and_image[:bucket]} -p #{bucket_and_image[:image]} --clear`

  debug_p "deregisterd and deleted #{image_id_str}"
end

# return -> {:bucket => string: name of bucket, :image => string: image name }
def get_bucket_and_image_name_by_id(image_id_str)
  begin
    bucket_and_image = `euca-describe-images #{image_id_str}`.scan(/^IMAGE\s+#{image_id_str}\s+(.+\.manifect\.xml)/)
  rescue
    debug_p "retry!"
    retry
  end
  
  return {:bucket => bucket_and_image[0], :image => bucket_and_image[1]}
end
private :get_bucket_and_image_name_by_id

class Machine
@instance_id_str
@@do_cache = false

  def set_instance_info(instance_id_str)
    @instance_id_str = instance_id_str
  end

  # return -> string: ID of vm instance
  def get_instance_info()
    return @instance_id_str
  end
  
  def destroy_instance()
    unless @instance_id_str
      puts "set_cloud_info() should be called appropriately before destroying instance"
      puts "exit destroy_instance() without terminating"
      return
    end

    unless @@do_cache
      terminate_instance(@instance_id_str)
    end
    
  end

  # set whether cache and reuse guest instance on Eucalyptus
  # if true value is set
  #     - destroy_instance(...) doesn't terminate instance
  def set_whether_do_cache(true_or_false)
    @@do_cache = true_or_false
  end
  
end

class Cloud
# TODO: enabling lib to find newly booted node without pinging
DHCP_LEASE_RANGE = "xxx.xxx.xxx.xxx"

CACHE_FILE_NAME = "./machine_cache_hash.yml"

# whether cache and reuse guest instance on Eucalyptus
# default value is false
@@do_cache = false

@@default_user
@@default_pass

  def self.Cloud(default_user,default_pass)
    @@default_user = default_user
    @@default_pass = default_pass
  end

  # return -> Machine : Machine instance applied network configuration and establised session
  def self.get_a_machine_with_imageup(params_hash)
    check_has_keys(params_hash,[:imagepath])
    
    unless params_hash[:imageid] = upload_and_register_image(params_hash[image_path_str],120)
      puts "uploading and registration of image failed"
      err_message_and_exit("I wll exit")
    end

    not_tested()
    return self.get_a_machine(params_hash)
  end


  # return -> Machine : Machine instance applied network configuration and establised session
  def self.get_a_machine(params_hash)

    # if @@do_cache true, Cloud class tries to reuse guest instance on Eucalyptus
    # whether exist appropriate instace is checked in terms of IP address
    if Cloud.is_exist_requested_machine(params_hash[:ipaddr]) && @@do_cache
      debug_p "reused a guset instance which has address #{params_hash[:ipaddr]}"
      # load instance ID corresponding to requested IP address from cache file
      machine_cache_hash = Cloud.load_machine_cache_info()
      instance_id = machine_cache_hash[params_hash[:ipaddr]]
    else
      # calling of this method isn't needed under normal conditions
      get_ipaddr_of_instance_pre()
      
      debug_p "executing euca-run-instance...."
      # ** Attention ** below is draft code
      instance_id = run_image(params_hash[:imageid])
      debug_p "euca-run-instance finished."

      #get a CLibIPAddr insance
      ipaddr = get_ipaddr_of_instance(instance_id)
      debug_p "IP address of the kicked instance: " + ipaddr.to_s

      debug_p "configure network setting to the kicked instance."
      vanilla_machine = Machine.new(ipaddr)
      vanilla_machine.set_auth_info(DEFAULT_USER,DEFAULT_PASS)
      vanilla_machine.establish_session()

      vanilla_machine.config_nw_interface(:ipaddr => params_hash[:ipaddr], :interface => params_hash[:interface], :netmask => params_hash[:netmask], :gateway => params_hash[:gateway], :onboot => "yes")
      vanilla_machine.set_resolver(:primary_ip => params_hash[:dns],:interface => params_hash[:interface])

      #reloads network configuration
      #10 seconds after, this will return with nil value
      # TODO: should eliminate assumption for platform
      debug_p "reload network configuration...."
      puts vanilla_machine.exec!("/sbin/service network restart", 10)
      debug_p "reloading of network configuration may have finished."

      # write machine info to cache file
      if @@do_cache
        machine_cache_hash = Cloud.load_machine_cache_info()
        debug_p "----------------loaded_hash------------------"
        debug_p machine_cache_hash.inspect()
        debug_p "class name of machine_cache_hash is #{machine_cache_hash.class}"
        debug_p "---------------------------------------------"
        machine_cache_hash[params_hash[:ipaddr]] = instance_id
        Cloud.dump_machine_cache_info(machine_cache_hash)
      end
      
    end
    
    configured_machine = Machine.new(params_hash[:ipaddr])
    configured_machine.set_auth_info(DEFAULT_USER,DEFAULT_PASS)
    configured_machine.establish_session()
    configured_machine.set_instance_info(instance_id)

    if @@do_cache
      configured_machine.set_whether_do_cache(true)
    end
    
    return configured_machine
  end

  # ipaddr -> CLibIPAddr
  # whether exist appropriate instace is checked in terms of IP address
  def self.is_exist_requested_machine(ipaddr)
    return is_exist_by_ping(ipaddr)
  end

  # ** Attention ** this is quick-fix implementation
  #                 this method can't work on parallel kicking
  #
  # return -> CLibIPAddr : xxx
  def self.get_ipaddr_of_instance(instance_id)
    unless @@pre_alived_hash
      err_message_and_exit("get_ipaddr_of_instance_pre() should be called on the eve of run_image(...)")
    end

    debug_p @@pre_alived_hash.inspect()
    
    while(true)
      alived_hash = find_machines_on_range_by_ping(DHCP_LEASE_RANGE)
      
      # find difference
      alived_hash.delete_if{ |key,value| @@pre_alived_hash.has_key?(key)}

      if alived_hash.size == 1
        debug_p alived_hash.inspect()
        ret = alived_hash.shift()[0]
        debug_p "found #{ret}"
        return CLibIPAddr.new(ret)
      elsif alived_hash.size > 1
        err_message_and_exit("There may be other booting machine!")
      end
      sleep 1 #leave a space
    end

  end

  # call of this method isn't needed under normal conditions
  # this method should be called on the eve of run_image(...)
  def self.get_ipaddr_of_instance_pre()
    @@pre_alived_hash = find_machines_on_range_by_ping(DHCP_LEASE_RANGE)
  end

  # set whether cache and reuse guest instance on Eucalyptus
  # if true value is set
  #     - get_a_machine(...) tries to reuse guest instance on Eucalyptus
  #     - destroy_instance(...) of Machine class doesn't terminate instance
  #     - write kicked machine info to cache file
  def self.set_whether_do_cache(true_or_false)
    @@do_cache = true_or_false
  end

  # machine_cache_hash -> hash : {"xxx.xxx.xxx.xxx" => "i-xxxxxxx", ... }
  def self.dump_machine_cache_info(machine_cache_hash)
    file = open(CACHE_FILE_NAME,"w")
    YAML.dump(machine_cache_hash,file)
    file.close()
  end

  # return -> hash: {"xxx.xxx.xxx.xxx" => "i-xxxxxxx", ... }
  # if chache file doesn't exist, return a empty hash
  def self.load_machine_cache_info()
    if File.exist?(CACHE_FILE_NAME)
      ret_hash = nil
      open(CACHE_FILE_NAME){ |file|
        ret_hash = YAML.load(file)
      }

      return ret_hash
    else
      return Hash.new()
    end
  end
  
end


# check source_certificate.sh has executed correctly
unless ENV["EC2_URL"]
  puts "ERROR: please run command below before use this library with eucalyptus plugin!!\n      \"source ./utility_scripts/source_certificate.sh\"\n"
  exit()
end

