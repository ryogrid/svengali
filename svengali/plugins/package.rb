class Machine

  def install_package(package_name_str)
    return @ssh.exec!(ExtStr.cmd["package_install"] + " " + package_name_str)
  end
  
end
