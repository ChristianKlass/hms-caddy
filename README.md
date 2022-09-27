# Home Media Server

This is a home media server project for me to learn how Docker and Docker-Compose works. This is really a journey of my self-learning adventure, and I may make a lot of changes to things as I learn more about how the things work.

I intend to make it able to automatically download Movies and TV series using softwares such as Sonarr and Radarr. Of course, I'm not actually going to use it, because we all know downloading movies is illegal. But I think it's still an interesting project and I hope I learn a lot from it.

## How To Use

1. Make sure you've installed the prerequisites (From the Before You Start section):
   - Installed Docker and Docker-Compose
   - Set the environment variables
2. In the same directory as the `docker-compose.yml`, run the command:

```
docker-compose up -d
```

## Using Docker Volumes

**Note:** I know that I don't use the Docker volumes in this build, and you totally can if you want. I just want it to be easy to move my stuff around if/when I need to. In my experience, Docker volumes are clunky to move around. I can't just copy a volume from one computer to another easily. If this is possible, please let me know, it would be nice.

To use Docker volumes, change the `docker-compose.yml` file to the following. I'll just use Loki as an example (because it's small), do the same for the rest of the services:

```
version: '3.6'

volumes:
  loki-config: {}

services:
  loki:
  image: grafana/loki:latest
  container_name: loki
  hostname: loki
  restart: always
  command:
    - '--config.file=/etc/loki/local-config.yml'
  env_file:
    - './env/common.env'
  expose:
    - '3100'
  volumes:
    - 'loki-config:/etc/loki:ro'
```

So as you can see, it's as simple as adding a new volume (via the `volumes` key), and changing the service definition to use the new volume (via the `- 'loki-config:/etc/loki:ro'`).

## Before You Start

Here are some prerequistes you need to install before you can use this Home Media Server.

### Environment Variables

You need to add the following to your environment variables. I don't know the best way to do it, but I use the `/etc/environment` file. If the file doesn't exist, create it:

```
TZ=Asia/Singapore # Change this to your timezone in this format
ROOT_URL=some.address # The address you'd like to access your server from.

PUID=1000
PGID=1001
USERDIR=/path/to/keep/stuff             # I use this to store the media/download/config stuff

```

To get the PUID and PGID, you can run `id` in your terminal and it will give you some output like:

```
uid=1000(mark) gid=1000(mark) groups=1000(mark),10(wheel),1001(docker)
```

The important ones you're looking for are `uid` (PUID) and the `gid` for docker (PGID).

Also, I've stopped using the environment variables directly in the `docker-compose.yml` file. I'm using `.env` files now. I just think it's neater. For example, I have a `common.env` file which I want all the services to use:

```
# common.env
PUID=${PUID}
PGID=${PGID}
TZ=${TZ}
```

Then I use it in the `docker-compose.yml` with the `env_file` key like so (let's use Loki as an example again because it's short):

```
# docker-compose.yml
loki:
  image: grafana/loki:latest
  container_name: loki
  hostname: loki
  restart: always
  command:
    - '--config.file=/etc/loki/local-config.yml'
  env_file:
    - './env/common.env'
  expose:
    - '3100'
  volumes:
    - './config/loki:/etc/loki:ro'
```

So you can use this for any of the environment variables you need, so you don't have to put everything in one file, like `prometheus.env`, `grafana.env`, etc.

### Docker

You'll also need to install Docker and Docker-Compose. You can do so by following the [official instructions](https://docs.docker.com/engine/install/) from their website.

Basically, I'm using Fedora, I just need to do add the repository with the below commands.

If you're using some other distro, follow the instructions they've provided on their instructions:

```
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
```

Then do the install with the package manager:

```
sudo dnf install docker-ce docker-ce-cli containerd.io
```

You can also use the [convenience script](https://docs.docker.com/engine/install/fedora/#install-using-the-convenience-script) they've provided, but I've personally never used it.

Remember to follow the [post installation steps](https://docs.docker.com/engine/install/linux-postinstall/). It makes life a lot easier.

### Docker Compose

Installing [Docker Compose](https://docs.docker.com/compose/install/) is much easier. Obviously, you'll need to install Docker first, otherwise it won't do anything.

Just download the following file to the `/usr/local/bin/` folder and make it executable:

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

Then you'll be able to run the `docker-compose` commands.

## Media server

**Note:** For most of these apps, you'll need to first expose their port using the `docker-compose.yml` so that you can access the web UI. You can do this with the `ports` key:

```
sonarr:
  image: linuxserver/sonarr:preview
  container_name: sonarr
  hostname: sonarr
  expose:
    - '8989'
  ports:
    - '8989:8989'
  ...
```

The `expose` and `ports` keys are different.

I don't think the `expose` does anything, it's more like a reminder that these ports are exposed **within** the docker network. This means that you can do access Sonarr within the network with http://sonarr:8989. It seems to work without it as well. I just use it as a way to document which ports are open for a particular app.

Anyway, the info about this can be found in the [Docker-Compose documentation](https://docs.docker.com/compose/compose-file/#expose).

To try this, you can go into a container which can `ping`. I like to use the Grafana container, because :shrug:

```
docker exec -it grafana bash

# you'll get a response similar to this:
bash-5.0$ ping sonarr
PING sonarr (172.28.0.9): 56 data bytes
ping: permission denied (are you root?)
```

The ping won't actually work, but you can see that they'll resolve the `sonarr` name to the an IP address.

The `ports` key maps the internal container port to the host's port so that you can access it. This can also be found in the [Docker-Compose documentation](https://docs.docker.com/compose/compose-file/#ports) as well.

Ports are mapped in a `host-port:container-port` configuration. It works like this:

```
ports:
  - '8989:8989' #this maps the host's port 8989 to the container's port 8989.
```

This example is not particularly helpful, but it's what was done. :3 So to access the container, you can do `http://<host.ip.address>:8989`.

For a more helpful example, let's pretend we want to map host port `1234` to Sonarr's `8989` port, so that we can access Sonarr with `http://<host.ip.address>:1234`:

```
ports:
  - '1234:8989' #it's always <host-port>:<container-port>
```

### Prowlarr

**From their Website:** Prowlarr is an indexer manager/proxy built on the popular arr .net/reactjs base stack to integrate with your various PVR apps. Prowlarr supports management of both Torrent Trackers and Usenet Indexers. It integrates seamlessly with Lidarr, Mylar3, Radarr, Readarr, and Sonarr offering complete management of your indexers with no per app Indexer setup required (we do it all).

It's a single point of indexing and translates it to a format that Sonarr and Radarr can understand (I think).

Read more about it on their [Github](https://wiki.servarr.com/prowlarr).

### Sonarr

**From their website:** Radarr is a movie collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new movies and will interface with clients and indexers to grab, sort, and rename them. It can also be configured to automatically upgrade the quality of existing files in the library when a better quality format becomes available.

Remember to add your media and download folders:

```
volumes:
  - '${USERDIR}/Downloads/completed:/downloads'
  - '${USERDIR}/media/tv-shows:/tv-shows'
```

Read more about it on their [Github](https://hub.docker.com/r/linuxserver/radarr) and on their [official website](https://radarr.video/).

### Radarr

**From their Github:** Sonarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

Remember to add your media and download folders:

```
volumes:
  - '${USERDIR}/Downloads/completed:/downloads'
  - '${USERDIR}/media/movies:/movies'
```

Read more about it on their [Github](https://github.com/Sonarr/Sonarr) and on their [official website](https://sonarr.tv/).
