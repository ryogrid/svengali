#! /bin/ruby
# -*- coding: utf-8 -*-
require "svengali/svengali"

#プログラム開始までにマシン3台がセットアップされていることを仮定
#DHCP経由でネットワーク回りの設定は行われておりそのアドレスも把握しているとする
#各マシンには統一したユーザ名でリモートログインできるものとする

#デフォルトはRedhat系ディストリビューションの環境を想定
#他の環境で使う場合は以下のように指定
#change_platform("debian")

user_name = "xxxxxxxx"
password = "xxxxxxxx"

IPADDR_BASE = CLibIPAddr.new("xxx.xxx.xxx.xxx")

MACHINE_NUM = 1
nodes = Array.new(MACHINE_NUM)

tmp_ipaddr = IPADDR_BASE.dup()
MACHINE_NUM.times{ |n|
  nodes[n] = Machine.new(tmp_ipaddr)
  nodes[n].set_auth_info(user_name,password)
  #コマンドの発行が可能な通信路を確保する
  nodes[n].establish_session() 
  puts nodes[n].exec!("uname -v")
  #change_platformしていない場合はyumが利用される
  puts nodes[n].install_package("xxxx")
  tmp_ipaddr.inc!()
}

nodes.each{ |a_node|
    #設定ファイルを編集
    sshd_conf = a_node.get_config_file("xxxxxxx.xxx")
    sshd_conf.replace_col("xxxxxx","xxxxxx")
    sshd_conf.save()
}

##実験開始
nodes.each{ |a_node|
   #スクリプトを転送
   a_node.push_a_file("./xxxx.sh","/home/xxx/xxxx.sh")

   #実験用のスクリプトを実行
   puts a_node.exec_script_on("/home/xxx/xxxx.sh,"","/home/xxx")
}
