## Syntax For push the images
    ```
    docker tag <SOURCE_IMAGE>:<TAG> <TARGET_IMAGE>:<TAG>
    ```
Example using postgres:18.4-alpine:
## Tag it:

```
docker tag postgres:18.4-alpine localhost:5000/my-postgres:v1
```

## Push it:
```
docker push localhost:5000/my-postgres:v1
```
Check UI: Refresh [http://127.0.0.1:8083](http://127.0.0.1:8083) to see my-postgres listed!

## Pull Images
```
docker pull localhost:5000/my-alpine:v1
```
