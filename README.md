# aliddns

## 启动

### 二进制

```shell
nohup aliddns --key <key> --cert <cert> --domain <domain> 2>&1 >aliddns.log &
```

### Docker

```shell
docker run \
-d \
--name aliddns \
--restart=unless-stopped \
--env ALIDDNS_KEY=<KERY> \
--env ALIDDNS_CERT=<CERT> \
--env ALIDDNS_DOMAIN=<DOMAIN> \
uhub.service.ucloud.cn/naturelr/aliddns:latest
```
