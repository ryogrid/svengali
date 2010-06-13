require 'rubygems'
gem 'net-ssh'
require 'net/ssh'
require 'timeout'

class SSH
  @host
  @user_name
  @password
  @session
  @shell
  @sftp_session

  attr_reader :sftp_session
  attr_reader :session

  def initialize(host,user_name=nil,password=nil)
    if user_name || password
       @user_name = user_name
       @password = password
       initialize(host)
    else #substitute of constructor which has no argument
      @host = host
      @terminator = ""

      wait_until_ssh_connectable(CLibIPAddr.new(host))
      
      if @user_name && @password #if initialized with user_name and password
        debug_p "Try Net::SSH.start()!"
        @session = Net::SSH.start(@host, @user_name,:password => @password)
      elsif @user_name #if initialized with user_name
        @session = Net::SSH.start(@host, @user_name)
      end
      debug_p "Net::SSH.start finished."
      @sftp_session = @session.sftp.connect()
    end
  end

  def close
    @session.close()
  end

  #exec and return string of stdout
  #this method blocks until remote call is finished
  #if execution is timeouted, this func returns nil

  # return value : String of stdout or stderr
  def exec!(command_str,time_out = nil)
    debug_p "exec! -> \"#{command_str}\""

      begin
        timeout(time_out) do
          return_val = ""
          @session.exec!(command_str) { |ch, stream, data|
            if stream == :stdout
              return_val += data
            elsif stream == :stderr
              return_val += data
            end
          }
          return return_val
        end
      rescue TimeoutError
        return nil
      end
  end

  # exec and return string of stdout
  # this method blocks until remote call is finished

  # return value : nothing
  def exec(command_str)
    debug_p "exec -> \"#{command_str}\""

    @session.exec(command_str)
  end
  
  def wait_until_ssh_connectable(host)
      # waits until ensure that ssh connection can be accept
      while(is_ssh_connectable(host) == false)
        sleep(1)
      end
  end

  # ipaddr -> CLibIPAddr: address of target machine
  def is_ssh_connectable(ipaddr)
    begin
      s = TCPSocket.open(ipaddr.to_s,22)
      s.close()
      return true
    rescue
      return false
    end
  end
  private "is_ssh_connectable"
end
