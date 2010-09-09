#in this file methods for file trasfer is defined
require 'rubygems'
gem 'net-sftp'
require 'net/sftp'

module FileIO
  BUFFER_SIZE = 1024
  
  def push_a_file(local_path,remote_path)
    debug_p("push_a_file from #{local_path} to #{remote_path}")
    @sftp_session.upload!(local_path,remote_path)
  end

  def pull_a_file(remote_path,local_path)
    debug_p("pull_a_file from #{remote_path} to #{local_path}")

    begin
      @sftp_session.download!(remote_path,local_path)
    rescue
      debug_p remote_path + " is not found on remote!!"
      return nil
    end
  end

  # push files on specified dir. only one level.
  # directories are not copied.
  def push_files(local_path,remote_path)
    debug_p("push_files from #{local_path} to #{remote_path}")
    local_dir = Dir.new(local_path)
    local_dir.each{ |path|
      unless File::ftype(local_path + "/" + path) == "directory"
        @sftp_session.upload!(local_path + "/" + path,remote_path + "/" + path)
      end
    }
  end

  #pull files on specified dir. only one level.
  def pull_files(remote_path,local_path)
    debug_p("pull_files from #{remote_path} to #{local_path}")
    @sftp_session.dir.foreach(remote_path){ |path|
      #unless path.name == "." || path.name == ".."
      #not directory
      unless /^d/ =~ path.longname
          @sftp_session.download!(remote_path + "/" + path.name,local_path + "/" + path.name)
      end
      #end
    }
  end

  # Note: if there is a directory which has same name with *local_path*, remote_directory is removed before coping directory
  def push_dir(local_path,remote_path)
    debug_p("push_dir from #{local_path} to #{remote_path}")
    begin
      @sftp_session.upload!(local_path,remote_path)
    rescue
      @ssh.exec!("rm -rf #{remote_path}")
      retry
    end
  end

  def pull_dir(remote_path,local_path)
    debug_p("pull_dir from #{remote_path} to #{local_path}")
    begin
      @sftp_session.download!(remote_path,local_path,:recursive => true)
    rescue
      debug_p remote_path + " is not found on remote!!"
      return nil
    end
  end

  # return -> boolean : 
  def is_exist(remote_path)
    begin
      @sftp_session.stat!(remote_path) { |response|
        #returns whether exists or not
        next response.ok?
      }
    rescue => e
      return false
    end
  end


  def get_contents_remote(remote_filepath_str)
    debug_p("get_contents_remote from #{remote_filepath_str}")
    handle = @sftp_session.open!(remote_filepath_str)
    contents = String.new()
    offset = 0
    while (data = @sftp_session.read!(handle, offset, BUFFER_SIZE)) != nil
      contents += data
      offset += BUFFER_SIZE
    end
    @sftp_session.close!(handle)

    return contents
  end

  # over writes contens from the start
  def write_contents_remote(remote_filepath_str,contents_str)
    debug_p("write_contents_remote to #{remote_filepath_str}")
    handle = @sftp_session.open!(remote_filepath_str,"w")
    @sftp_session.write!(handle, 0, contents_str)
    @sftp_session.close!(handle)
  end
    
end