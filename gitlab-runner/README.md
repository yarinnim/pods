# GitLab Runner Setup Guide

This guide walks through deploying, registering, and verifying a **GitLab Runner** container.

---

## 1. Deploy the GitLab Runner Container

Run the following command to start the `gitlab-runner` container in detached mode with persistent configuration and Docker socket access:

```bash
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/gitlab-runner/config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest
```

---

## 2. Register the Runner

You can register the runner using either the fast **one-line registration** or the **interactive prompt**.

### Option 1: One-Line Registration (Recommended)

1. Navigate in GitLab:
    **Project / Group** → **Settings** → **CI/CD** → **Runners** → **New project runner**.
2. Set your description and tags (e.g., `sonar-runner`), then click **Create runner**.
3. GitLab will generate a registration command containing your token:
   ```bash
   gitlab-runner register --url [https://gitlab.mydomain.com](https://gitlab.mydomain.com) --token YOUR_GENERATED_TOKEN
   ```
4. Run that command directly inside your running container:
   ```bash
   docker exec -it gitlab-runner gitlab-runner register \
     --url [https://gitlab.mydomain.com](https://gitlab.mydomain.com) \
     --token YOUR_GENERATED_TOKEN
   ```

---

### Option 2: Interactive Registration

1. Enter the container's registration wizard:
   ```bash
   docker exec -it gitlab-runner gitlab-runner register
   ```
2. Answer the prompts when requested:
   * **GitLab URL:** `https://gitlab.mydomain.com`
   * **Token:** *(Paste your token copied from GitLab)*
   * **Description:** `runner-for-sonarqube`
   * **Tags:** `sonar-runner, docker`
   * **Executor:** `docker`
   * **Default Docker Image:** `alpine:latest`

---

## 3. Verify Runner Status

Verify that the runner is online and properly registered:

* **List registered runners:**
  ```bash
  docker exec -it gitlab-runner gitlab-runner list
  ```
* **View container logs:**
  ```bash
  docker logs -f gitlab-runner
  ```


