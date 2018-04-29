# Fichiers de configuration Splunk

#### deploymentclient.conf
```
[target-broker:deploymentServer]
targetUri = 5.196.225.64:8089
```

#### outputs.conf
[tcpout]
defaultGroup = splunk

[tcpout:splunk]
server = slmaq020.cus.fr:9997

#### inputs.conf
[monitor:///var/log/syslogd/firewall/*/*.log]
host_segment = 5
sourcetype = 
index = 
