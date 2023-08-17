Deploy Kubernetes with Ansible Semaphore UI and Kubespray
------------
This project is based on the [Ansible Semaphore](https://github.com/ansible-semaphore/semaphore) project. 
### Install semaphore-kubespray with Docker

Build and run the semaphore-kubespray docker image

```sh
cd semaphore
docker compose build
docker compose up -d
```

if "docker-compose build" or "docker compose build" does't work try to cd into the directory where your Dockerfile is and run the below command to build the image using docker build instead

```sh
docker build -t {image-name}:{version} .
e.g
docker build -t kubespray-semaphore:2.8.90 .
```

Login to the web-UI at https://localhost:3000 or https://<YOUR_SERVER_IP>:3000

License
------------
MIT License

Copyright (c) 2016 Castaway Consulting LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
