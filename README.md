## Examples

```
docker create \
	--name=unbound \
	-p 53:53 \
	-p 53:53/udp \
	--cap-add=NET_ADMIN \
	--restart unless-stopped
```
