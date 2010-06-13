require "thread"
require "#{LIBNAME}/ssh"
require "#{LIBNAME}/config"
require "#{LIBNAME}/util"
require "#{LIBNAME}/ext_string"

#module Machine
  class MachineMaster
    @@group = ThreadGroup.new
  end

  class Machine < MachineMaster
    include Config
    include FileIO

    #fields
    @user_name
    @host
    @ssh
    @sftp_session
    @password

    attr_reader :ssh

    def initialize(host=nil)
      if host == nil  #substitute of constructor which has no argument
#        include_plugin_modules()
      else
        @host = host.to_s()
        initialize()
      end
    end

#    def include_plugin_modules()
#      $to_load_modules.each{ |plugin_name|
#        self.extend( plugin_name.capitalize().intern )
#      }
#    end
#    private :include_plugin_modules

    def cleanup
      debug_p "start cleanup instance for " + @host
      @sftp_session.close_channel()
      @ssh.close()
      debug_p "finished cleanup instance for " + @host
      # @@group.list.each {|th| th.join }
    end

    def set_auth_info(user_name,password=nil)
      @user_name = user_name
      @password = password
    end

    def establish_session()
      debug_p "start establish_session to " + @host
      # Spawn worker threads

      th = Thread.new do
        debug_p "Initialization of Machine ##{@host} is started."
        if @user_name && @password
          @ssh = SSH.new(@host,@user_name,@password)
        elsif @user_name
          @ssh = SSH.new(@userneme)
        else
          debug_p "please set user name at leaset"
          exit()
        end
        debug_p "Initialization of Machine ##{@host} is finished."

        @sftp_session = @ssh.sftp_session
        @@group.add(th)
      end

      #wait util finishing initialize of @ssh object
      while @ssh == nil
        sleep(1)
      end

      debug_p "finished establish_session to " + @host
    end

    def exec(command_str)
      return @ssh.exec(command_str)
    end

    def exec!(command_str,timeout = nil)
      return @ssh.exec!(command_str,timeout)
    end

    # call exec!( command ) on specified path
    # TODO: change function name to exec_on!
    def exec_on(command_str,current_path_str)
      exec!("cd #{current_path_str};" + command_str)
    end

    # execute local script on remote
    # current_path_str -> string: if change of directory is not needed, please pass "."
    # use remote /tmp directory to store script file
    # TODO: change function name to exec_script_on!
    def exec_script_on(script_path_str,arguments_str,current_path_str)
      fname_str = File.basename(script_path_str)
      rempte_path_str = "/tmp/" + fname_str
      push_a_file(script_path_str,rempte_path_str)
      exec_on!("sh #{rempte_path_str} " + arguments_str,current_path_str)
    end

    def sftp()
      return @ssh.sftp_session
    end
    
  end
#end
