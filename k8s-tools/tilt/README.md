Faster Kubernetes Local Development with Tilt
==================


### Install Tilt

```sh
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
```


### Edit Tiltfile

```sh
# Set your image registry
docker_build('[YOUR REGISTRY URL]/microservices-demo-api',
             context='.',
             # (Optional) Use a custom Dockerfile path
             dockerfile='./deploy/api.dockerfile',
             # (Optional) Filter the paths used in the build
             only=['./api/app'],
             # (Recommended) Updating a running container in-place
             # https://docs.tilt.dev/live_update_reference.html
             live_update=[
                # Sync files from host to container
                sync('./api/app/', '/app/'),
                # Execute commands inside the container when certain
                # paths change
                run('pip install -r /app/requirements.txt',trigger=['./api/app/requirements.txt'])
             ]
)

# Set your kubeconfig context
allow_k8s_contexts('[YOUR KUBERNETES CONTEXT]')
```

### Start Tilt
```sh
cd microservices-demo
tilt up
```

### Web UI
View the web UI at http://localhost:10350

### Delete all deployments
```sh
cd microservices-demo
tilt down
```