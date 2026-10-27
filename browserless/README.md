# Browserless

Headless Chromium, run as a Swarm service on the `common` stack. Other services on the `backend` network reach it as `browserless`. The host port is `BROWSERLESS_PORT`.

The image supervises Chrome. This pod keeps that process from taking the machine down: shared memory is 2 GiB, session count and queue length are capped, overloaded calls are refused, and Swarm restarts the service if the process exits.

## Deployment

Settings live in `env.example`. `.env` is a symlink to that file, which is what `deploy.sh` and Compose read.

```bash
ln -sfn env.example .env
sudo ./deploy.sh
```

`deploy.sh` reads `.env`, creates the data directories, exports every setting, and runs `docker stack deploy` into the stack `common`. The service name comes from `SERVICE_NAME`.

Change a value in `env.example`, then run `sudo ./deploy.sh` again. Swarm applies environment variables at deploy time.

Check that it is up. Replace `TOKEN` with the value from `env.example`:

```bash
curl -fsS "http://127.0.0.1:3000/pressure?token=TOKEN"
```

## Public URL

`nginx.conf` publishes the service at `http://browserless.localhost.com` and proxies to `common_browserless:3000`. The proxy upgrades WebSocket connections, which Puppeteer and Playwright need.

The same service is also reachable as a subpath, for example `https://apps.localhost.com/browserless`. Paste `nginx-subpath.conf` inside that site's `server` block. Nginx strips `/browserless` before the request reaches Browserless. Connect there with the prefix in the client URL:

```text
wss://apps.localhost.com/browserless?token=TOKEN
wss://apps.localhost.com/browserless/chromium/playwright?token=TOKEN
```

Links that Browserless itself generates, such as `/sessions`, stay on the host root. `EXTERNAL` does not add the `/browserless` prefix.

Copy the host site into the nginx config directory, then reload nginx:

```bash
sudo cp nginx.conf /home/wwwroot/nginx-conf/conf.d/browserless.conf
sudo docker service update --force common_nginx
```

`EXTERNAL` in `env.example` is `https://browserless.mydomain.com`, so links Browserless generates use that host.

## How to connect

From the public site, the base URL is `https://browserless.mydomain.com`. From this host, it is `http://127.0.0.1:3000`. From another container on `backend`, it is `http://browserless:3000`. Put the token on the query string.

Puppeteer:

```js
import puppeteer from "puppeteer-core";

const browser = await puppeteer.connect({
  browserWSEndpoint: "wss://browserless.mydomain.com?token=TOKEN",
});

const page = await browser.newPage();
await page.goto("https://example.com");
console.log(await page.title());
await browser.close();
```

Playwright:

```js
import { chromium } from "playwright-core";

const browser = await chromium.connect(
  "wss://browserless.mydomain.com/chromium/playwright?token=TOKEN",
);

const page = await browser.newPage();
await page.goto("https://example.com");
console.log(await page.title());
await browser.close();
```

Close the browser when the work is finished. A session left open is held until `TIMEOUT`, and those sessions are what fill memory.

### Management endpoints

All of these accept `?token=TOKEN`.

| Path | What it returns |
|---|---|
| `/active` | Liveness. Empty `204` when the process is up. |
| `/pressure` | CPU, memory, running sessions, and queue depth. |
| `/sessions` | Browsers that are open right now. |
| `/metrics` | Session and performance metrics. |
| `/config` | The configuration the process is running with. |
| `/docs` | Built-in route documentation. |

`/function` runs caller-supplied code. Leave `TOKEN` set. With no token, that route is open to anyone who can reach the port.

## Stability

| Limit | Where | Value |
|---|---|---|
| Shared memory `/dev/shm` | `docker-compose.yml` | 512 MiB. This sits inside the 2560 MiB memory cap. |
| CPU | `docker-compose.yml` | 2 CPUs max, 0.5 reserved. A page can use both cores instead of stalling on one. |
| Memory | `docker-compose.yml` | 2560 MiB of the host's 4 GiB, 512 MiB reserved. Past the cap, Swarm kills this container only. |
| Processes | `docker-compose.yml` | 256. Stops a Chrome fork storm from exhausting the host. |
| Restart | `docker-compose.yml` | Swarm restarts the task on any exit, after 5 seconds. |
| Concurrent sessions | `CONCURRENT` | 1 running Chrome process. |
| Queue | `QUEUED` | 2 waiting requests, then new calls get `429`. |
| Session lifetime | `TIMEOUT` | 300000 ms. `-1` disables the timer. |
| Overload | `HEALTH` | Above 75% of the 2560 MiB cap, new sessions get `503`. |

The host has 2 CPUs and 4 GiB. This service may use both cores and at most 2560 MiB, which leaves about 1.5 GiB for the OS and the other containers. One Chrome session fits after 512 MiB is used for shared memory. The session timer is 5 minutes (`TIMEOUT=300000`). To run more, raise the memory limit and `CONCURRENT` together, then redeploy.

`MACHINE_STATS_SOURCE=cgroup` makes the health check use the container limit, so a busy host does not look like a full container.

## Mounts

| Host | Container | Purpose |
|---|---|---|
| `BROWSERLESS_DATA_PATH` | `DATA_DIR` (`/data`) | Cookies, cache, and profile data. Every session shares this directory. |
| `BROWSERLESS_DOWNLOADS_PATH` | `DOWNLOAD_DIR` (`/downloads`) | Files Chrome downloads. |
| `BROWSERLESS_SCRATCH_PATH` | `SCRATCH_DIR` (`/scratch`) | Per-session temp files. Kept out of the shared temp dir so they can be removed. |
| `BROWSERLESS_METRICS_PATH` | `/metrics` | `metrics.json` survives restarts. |
| `BROWSERLESS_FONTS_PATH` | `/usr/share/fonts/custom` | Extra fonts. Drop files in `./fonts` and redeploy. |
| `.env` → `env.example` | `/config/browserless.env` | The settings file, read-only. |

`deploy.sh` creates the data directories and makes them writable by uid `999`, which is the user inside the image. The image does not create those directories itself.

## Configuration

Defined in `env.example`. `.env` is only a symlink to it. Quotes are required when a value contains spaces or `*`.

### Deploy

| Variable | Default | Description |
|---|---|---|
| `SERVICE_NAME` | `browserless` | Swarm service name. Becomes `common_browserless`. |
| `BROWSERLESS_IMAGE` | `ghcr.io/browserless/chromium:v2.57.3` | Image. The tag includes the `v` prefix. |
| `BROWSERLESS_PORT` | `3000` | Port published on the host. The process listens on `PORT`. |
| `BROWSERLESS_DATA_PATH` | `/var/data/browserless/data` | Host path for profile data. |
| `BROWSERLESS_DOWNLOADS_PATH` | `/var/data/browserless/downloads` | Host path for downloads. |
| `BROWSERLESS_SCRATCH_PATH` | `/var/data/browserless/scratch` | Host path for scratch files. |
| `BROWSERLESS_METRICS_PATH` | `/var/data/browserless/metrics` | Host path for metrics. |
| `BROWSERLESS_FONTS_PATH` | `./fonts` | Host path for extra fonts. |

### Process

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Address the process binds inside the container. |
| `PORT` | `3000` | Port inside the container. |
| `EXTERNAL` | `https://browserless.mydomain.com` | Public URL used in links Browserless generates, such as `/sessions`. |
| `TOKEN` | | API token. Required for any deployment that is not only on localhost. |
| `STRICT_TOKEN_USE` | `false` | When `true`, `TOKEN` is required on every route. |

### Sessions

| Variable | Default | Description |
|---|---|---|
| `CONCURRENT` | `1` | Maximum Chrome sessions running at once. Further requests wait. |
| `QUEUED` | `2` | Maximum waiting requests. Above this, the response is `429`. |
| `TIMEOUT` | `300000` | Session limit in milliseconds. `-1` means no limit, and the caller must close the browser. |
| `RETRIES` | `2` | Launch retries. |
| `HEARTBEAT_INTERVAL` | `30000` | WebSocket heartbeat interval in milliseconds. Lower it behind a proxy that drops idle connections. |

### Storage

These are paths inside the container. They must match the volume targets in `docker-compose.yml`.

| Variable | Default | Description |
|---|---|---|
| `DATA_DIR` | `/data` | Profile directory. |
| `DOWNLOAD_DIR` | `/downloads` | Download directory. |
| `SCRATCH_DIR` | `/scratch` | Scratch directory. |
| `METRICS_JSON_PATH` | `/metrics/metrics.json` | Metrics file. Read on startup and written while running. |

### Security

| Variable | Default | Description |
|---|---|---|
| `CORS` | `false` | Send CORS headers. |
| `CORS_ALLOW_ORIGIN` | `*` | Allowed origins when CORS is on. |
| `CORS_ALLOW_METHODS` | `OPTIONS, POST, GET` | Allowed methods when CORS is on. |
| `CORS_ALLOW_HEADERS` | `*` | Allowed request headers when CORS is on. |
| `CORS_ALLOW_CREDENTIALS` | `true` | Allow credentials when CORS is on. |
| `CORS_EXPOSE_HEADERS` | `*` | Headers exposed to the browser when CORS is on. |
| `CORS_MAX_AGE` | `2592000` | Preflight cache, in seconds. |
| `ALLOW_GET` | `false` | Allow GET requests that carry a JSON body in the query string. |
| `ALLOW_FILE_PROTOCOL` | `false` | Allow pages to open `file://` URLs. |
| `DISABLE_BLOCKLIST` | `false` | When `true`, Chrome may navigate to localhost, private addresses, and cloud metadata endpoints. |
| `MAX_PAYLOAD_SIZE` | `10485760` | Largest accepted request body, in bytes (10 MiB). |

### Health

| Variable | Default | Description |
|---|---|---|
| `HEALTH` | `true` | Refuse new sessions when CPU or memory is over the limit. |
| `MAX_CPU_PERCENT` | `100` | CPU threshold. `100` keeps a single busy core from refusing work. |
| `MAX_MEMORY_PERCENT` | `75` | Memory threshold. Used when `HEALTH=true`. |
| `MACHINE_STATS_SOURCE` | `cgroup` | `cgroup` uses the container limit. Also `host` or `auto`. |
| `CPU_SAMPLE_INTERVAL_MS` | `1000` | How often CPU is sampled. |
| `CPU_EMA_ALPHA` | `0.3` | Weight of a new CPU sample in the moving average. |
| `CPU_OVERLOAD_HYSTERESIS` | `10` | Percentage points CPU must fall before new sessions are accepted again. |

### Logging

| Variable | Default | Description |
|---|---|---|
| `DEBUG` | `-*` | Debug namespaces. `*` is very noisy. `-*` turns them off. |
| `LOG_LEVEL` | `info` | `trace`, `debug`, `info`, `warn`, `error`, `fatal`, or `silent`. |
| `LOG_FORMAT` | `plain` | `json` for log collectors. |
| `ENABLE_DEBUGGER` | `false` | Serve the session debugger. Off keeps that UI out of the memory cap. |
| `OTEL_ENABLED` | `false` | OpenTelemetry export. Set the collector endpoint in the environment when this is `true`. |

## Logs

```bash
docker service logs -f common_browserless
```
