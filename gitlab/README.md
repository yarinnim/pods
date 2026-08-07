# GitLab 

This project deploys GitLab Community Edition (CE) as a Docker Swarm stack.
The deployment is configured through environment variables, making
it easy to customize the GitLab URL and other settings without modifying the
stack files.

## Quick Start 

To deploy the gitlab, we need to define the env variable located in the 
`.env` file in the root directory of the gitlab as the following:

```bash
# The content of .env file
GITLAB_IMAGE=gitlab/gitlab-ce:latest
GITLAB_HOSTNAME=gitlab.qubehub.loc
GITLAB_EXTERNAL_URL=https://gitlab.mydomain.com

# Host port mapping
GITLAB_HTTP_PORT=80
GITLAB_HTTPS_PORT=443
GITLAB_SSH_PORT=22

# Data persistence paths on the host
GITLAB_CONFIG_DIR=/var/data/gitlab/config
GITLAB_LOGS_DIR=/var/data/gitlab/logs
GITLAB_DATA_DIR=/var/data/gitlab/data
```

After the `.env` variables are properly set, you can deploy the service
using existing deploy script using `sudo`:

```bash
sudo ./deploy.sh
```
    
After deployment, gitlab takes around 3 - 5 minutes to start. We can monitor the starting process by using the following docker command:

```bash
# Monitor the processes of the service common_gitlab
sudo docker service ps common_gitlab

# Or trace the service log as
sudo docker service logs -f common_gitlab
```

> [!NOTE]
> After the gitlab is deployed, it will generate a root password (`root` user)
> into `initial_root_password` file which located under the `config` folder
> of the gitlab configuration folder. Based on `.env` the configuration file
> is located at `/var/data/gitlab/config/initial_root_password`.
> And need to remember that the file will be deleted within next 24 hours.

## Trouble Shooting
If the service already up, but from proxy (`nginx`) access to the service is
blocked by `502` HTTP status, we need to check if the internal services
are up properly or not:

```bash
# Check status
sudo docker exec -it CONTAINER_ID gitlab-ctl tail puma
sudo docker exec -it CONTAINER_ID gitlab-ctl tail gitlab-workhorse

# Start if it's down
sudo docker exec -it CONTAINER_ID gitlab-ctl restart puma
sudo docker exec -it CONTAINER_ID gitlab-ctl restart gitlab-workhorse
```

## Gitlab on lite server

As recommendation, the server should be with at least **4Gb** of RAM,
but we can host it on lite server (2Gb of RAM and 2 Cores of CPU)
by optimizing its behavior based on few tricks and configuration.

### Increase the `/swap`
The `/swap` partition is a dedicated section of server hard drive 
reserved to act as an extension of the server physical RAM. When
the system runs low on RAM, it automatically swaps the idled
or background data to `/swap` partition, freeing up active memory
for the programs currently running. To create the `/swap` partition
as the following:

```bash
# Create a file with 8G size at /swapfile
sudo fallocate -l 8G /swapfile 
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make /swapfile mounted automatically when reboot
echo '/swapfile none swap ws 0 0' | sudo tee -a /etc/fstab 

# Optimize agressiveness of swapping
sudo sysctl vm.swappiness=10
echo 'vm.swappiness=10' | sudo tee -a /sysctl.conf
```

### Optimize Gitlab

There are few tricks that we can twist to make the lite server can
handle the gitlab service. The following is to touch few configuration
to make the resource consumption less and fits to lite server:

```rb
# /var/data/gitlab/config/gitlab.rb
external_url 'https://gitlab.mydomain.com'

# Single-process Puma mode (saves ~400MB)
puma['worker_processes'] = 0
puma['min_threads'] = 1
puma['max_threads'] = 4

# Reduce Sidekiq memory usage
sidekiq['concurrency'] = 5

# Reduce PostgreSQL share buffer (saves ~250MB)
postgresql['shared_buffers'] = "128MB"

# Disable heavy background monitoring services (saves ~400MB)
prometheus_monitoring['enable'] = false
grafana['enable'] = false
alertmanager['enable'] = false
gitlab_exporter['enable'] = false
```

After the configuration changed, we need to run the `reconfigure` to 
apply the new configuration, and then restart the gitlab with the
following command:

```bash
sudo docker exec -it CONTAINER_ID gitlab-ctl reconfigure
sudo docker exec -it CONTAINER_ID gitlab-ctl restart
```