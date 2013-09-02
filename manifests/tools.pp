# This manifest is managed using cosmos

class cosmos::tools {
   $tools = ["vim","traceroute","tcpdump","molly-guard","less","rsync","screen","strace","lsof"]
   package { $tools: ensure => latest}
}
