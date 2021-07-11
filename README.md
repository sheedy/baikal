# Baikal

> Lightweight CalDAV+CardDAV server. <http://baikal-server.com/>

Original Docker Image Source: <https://github.com/ckulka/baikal-docker>

If already installed and `Specific` directory is present, add the following to the `Dockerfile` or mount the file into the container.

`RUN touch /var/www/baikal/baikal/Specific/ENABLE_INSTALL`

## Manual backup/restore

```sh
# Backup
docker cp baikal:/var/www/Specific/db/db.sqlite db.sqlite

# Restore
docker cp db.sqlite baikal:/var/www/Specific/db/db.sqlite
```

## ToDo

- Add mail <https://github.com/ckulka/baikal-docker/pull/32>
