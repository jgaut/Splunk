# API

#### Recherche et réupération des résultats via http
```
curl -ku user:pass https://localhost:8089/servicesNS/admin/search/search/jobs/export -d search="search index=stream source=\"stream:tcp\" earliest=-7d | dedup src_ip dest_ip | table src_ip dest_ip | sort src_ip" -d output_mode=json
```

#### Recherche et réupération des résultats via http avec parsing json en bash (jq)
```
curl -ku user:pass https://localhost:8089/servicesNS/admin/search/search/jobs/export -d search="search index=stream source=\"stream:tcp\" earliest=-7d | dedup src_ip dest_ip | table src_ip dest_ip | sort src_ip" -d output_mode=json | jq '. | {preview: false, src_ip: .result.src_ip, dest_ip: .result.dest_ip}'
```


curl -k -u 'admin:Adista!2016'  https://localhost:8089/servicesNS/-/search/search/jobs/export?output_mode=raw -d search='| loadjob 1519664684.91674' > skype.raw