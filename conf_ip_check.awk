BEGIN {
     debug=1
}

/^cm device / {
     device_count++
     device[device_count,"name"]=$3
     device[device_count,"self"]="false"
     while ($0!~/^\}/) {
          getline
          if ($1=="configsync-ip") {
               device[device_count,"configsync"]=$2
          }
          if ($1=="hostname") {
               device[device_count,"hostname"]=$2
          }
          if ($1=="management-ip") {
               device[device_count,"mgmt"]=$2
          }
          if ($1=="mirror-ip") {
               device[device_count,"mirror"]=$2
          }
          if ($1=="self-device") {
               device[device_count,"self"]=$2
          }
          if ($1=="ip") {
               device[device_count,"unicast_count"]++
               device[device_count,"unicast",device[device_count,"unicast_count"]]=$2
          }
     }
}

/^sys management-route / {
     management_route_count++
     management_route[management_route_count,"name"]=$3
     while ($0!~/^\}/) {
          getline
          if ($1=="gateway") {
               management_route[management_route_count,"gateway"]=$2
          }
          if ($1=="network") {
               management_route[management_route_count,"network"]=$2
          }
     }
}

/^net self / {
     self_count++
     self[self_count,"name"]=$3
     while ($0!~/^\}/) {
          getline
          if ($1=="address") {
               self[self_count,"address"]=$2
          }
     }
}

/^sys ntp / {
     while ($0!~/^\}/) {
          getline
          if ($1=="servers") {
               while (NF>=4) {
                    ntp_servers_count++
                    ntp_server[ntp_servers_count,"ip"]=$3
                    #print "NTP SERVER "$3
                    $3=""
                    $0=$0
               }
          }
     }
}

/^sys snmp / {
     while ($0!~/^\}/) {
          getline
          if ($1=="allowed-addresses") {
               while (NF>=4) {
                    snmp_servers_count++
                    snmp_server[snmp_servers_count,"ip"]=$3
                    #print "snmp SERVER "$3
                    $3=""
                    $0=$0
               }
          }
     }
}

/^sys syslog / {
     while ($0!~/^\}/) {
          getline
          if ($1=="host") {
               syslog_server_count++
               syslog_server[syslog_server_count,"ip"]=$2
          }
     }
}


END {
     for (i=1;i<=management_route_count;i++) {
          print "Management Route "management_route[i,"name"]" "management_route[i,"network"]" "management_route[i,"gateway"]
     }

     for (i=1;i<=self_count;i++) {
          print "Self IP "self[i,"name"]" "self[i,"address"]
     }

     for (i=1;i<=ntp_servers_count;i++) {
          print "NTP Server "ntp_server[i,"ip"]
     }

     for (i=1;i<=snmp_servers_count;i++) {
          print "SNMP Server "snmp_server[i,"ip"]
     }

     for (i=1;i<=syslog_server_count;i++) {
          print "Syslog Server "syslog_server[i,"ip"]
     }
    
     for (i=1;i<=device_count;i++) {
          print "Device "device[i,"name"]" Hostname      "device[i,"hostname"]
          print "Device "device[i,"name"]" self          "device[i,"self"]
          print "Device "device[i,"name"]" configsync-ip "device[i,"configsync"]
          print "Device "device[i,"name"]" mirror-ip     "device[i,"mirror"]
          for (j=1;j<=device[i,"unicast_count"];j++) {
          print "Device "device[i,"name"]" unicast-ip    "device[i,"unicast",j]
          }
     }
}
