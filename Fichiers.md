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
```

#### inputs.conf
```javascript
[monitor:///var/log/syslogd/firewall/*/*.log]
host_segment = 5
sourcetype = 
index = 
```