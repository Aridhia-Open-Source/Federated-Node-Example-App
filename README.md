# Federated node shiny app - DEMO

This repo collects the code for the shiny app to be hosted by a workspace in the DRE [miniapp/](./miniapp) and the docker image used to run a task in the Federated Node [docker/](./docker/)

### Docker image
It's a very simple script added to the rocker/shiny-verse:4.3.2 image, plus some dependencies.

To build it, run
```sh
./build.sh
```
it will create an image called `ghcr.io/aridhia-open-source/rtest:latest`

push it with
```sh
docker push ghcr.io/aridhia-open-source/rtest:latest
```

### Miniapp

Is a simple R script based on `shiny` where a dropdown menu and couple of buttons will be shown to interact with the FN.

Copy the whole folder content into a `Blank mini app` folder in the DRE and it should be ready to go.

One additional step might require the whitelisting of the federated node endpoint in the workspace settings.

testing change
