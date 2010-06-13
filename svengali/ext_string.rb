# manages externarized strings on YAML files
class ExtStr
  @@command_accessor = nil
  @@path_accessor = nil

  def self.path()
    unless @@command_accessor && @@path_accessor
      self.init()
    end

    return @@path_accessor
  end

  def self.cmd()
    unless @@command_accessor && @@path_accessor
      self.init()
    end

    return @@command_accessor
  end

  def self.init()
    @@command_accessor = ExtStrAccessor.new(File::dirname(__FILE__) + "/ext_string/command.yml",$platform_name)
    @@path_accessor = ExtStrAccessor.new( File::dirname(__FILE__) + "/ext_string/path.yml",$platform_name)
  end
#  private_class_method :init

end

class ExtStrAccessor
@contents_hash
@first_level

  def initialize(file_name_str,first_level_name)
    @contents_hash = YAML.load_file( file_name_str )
    @first_level = first_level_name
  end

  def [](key)
    val = @contents_hash[@first_level][key]
    if val
      return val
    else
      default_val = @contents_hash["default"][val]
      if default_val
        return default_val
      else
        debug_p "key( #{key.to_s} ) is not found on even default hash!"
      end
    end
  end
  
end
