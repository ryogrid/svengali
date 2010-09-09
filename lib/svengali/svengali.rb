#main routine of svengali

# slash of tails is to avoid a baffling bug
LIBNAME = "svengali/"

require "#{LIBNAME}/file_io"
require "#{LIBNAME}/machine"
require "#{LIBNAME}/ssh"
require "#{LIBNAME}/util"

#load the defualt platform in the meantime
require "#{LIBNAME}/platforms/default"

#load default plugins
load_plugin("machine_config")
load_plugin("package")

#all global variables defined on this library is here
$platform_name = "default"
