# Fichiers de configuration Splunk

#### deploymentclient.conf
```javascript
[target-broker:deploymentServer]
targetUri = 5.196.225.64:8089
```

#### outputs.conf
```javascript
[tcpout]
defaultGroup = splunk
```

```javascript
[tcpout:splunk]
server = slmaq020.cus.fr:9997
maxQueueSize = 100MB
```
#### inputs.conf
```javascript
[monitor:///var/log/syslogd/firewall/*/*.log]
host_segment = 5
sourcetype = 
index = 
persistentQueueSize = 100MB
```
#### server.conf
```javascript
[indexer_discovery]
pass4SymmKey = my_secret
indexerWeightByDiskCapacity = true
```

#### outputs.conf
```javascript
[indexer_discovery:master1]
pass4SymmKey = my_secret
master_uri = https://10.152.31.202:8089

[tcpout:group1]
autoLBFrequency = 30
forceTimebasedAutoLB = true
indexerDiscovery = master1
useACK=true

[tcpout]
defaultGroup = group1
```

#### wmi.conf
```javascript
[WMI:TailApplicationLogs]
interval = 10
event_log_file = Application, Security, System
server = srv1, srv2, srv3
disabled = 0
current_only = 1
batch_size = 10
```