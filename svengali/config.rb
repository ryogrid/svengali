#for StringIO
require "stringio"

module Config

  # if there isn't a file which has specified file name, New file is created.
  def get_config_file(remote_filepath_str)
    # passed @sftp_session is not one of ConfigFile
    return ConfigFile.new(remote_filepath_str,@sftp_session)
  end

class ConfigFile
  include FileIO

    @remote_filepath_str
    @sftp_session
    #Net::SFTP::Request
    @config_file_contents

    #ssh_session => Net::SFTP::Session
    #ConfigFile class doesn't manage passed sftp_session value
    def initialize(remote_path_str,sftp_session)
      @sftp_session = sftp_session

      @remote_filepath_str = remote_path_str
      if is_exist(remote_path_str)
#        config_file = @sftp_session.open!(remote_path_str)
        @config_file_contents = get_contents_remote(@remote_filepath_str)
      else
        @config_file_contents = ""
      end

    end

    #replace columns which has specified content
    def replace_col(original_col_str,replaced_col_str)
      orig_contents_io = StringIO.new(@config_file_contents)
      replaced_contents_io = StringIO.new()
      orig_contents_io.each_line { |line|
         replaced_contents_io.puts(line.gsub(original_col_str,replaced_col_str))
      }
      orig_contents_io.close()
      replaced_contents_io.close()

      @config_file_contents = replaced_contents_io.string
    end

    def append_str(str)
      @config_file_contents += str
    end

    #remove all columns which contains passed string
    def remove_col_by_str(str)
      orig_contents_io = StringIO.new(@config_file_contents)
      removed_contents_io = StringIO.new()
      orig_contents_io.each_line { |line|
         unless line.index(str)
           removed_contents_io.puts(line)
         end
      }
      orig_contents_io.close()
      removed_contents_io.close()

      @config_file_contents = removed_contents_io.string
    end

    #remove columns which matched passed regular expression
    def remove_col_by_regexp(regexp)
      not_inp()
    end
    
    #save modified content
    def save
      write_contents_remote(@remote_filepath_str,@config_file_contents)
    end
    
  end
end
