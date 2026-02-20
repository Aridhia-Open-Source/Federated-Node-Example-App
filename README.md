# Federated node shiny app - DEMO

This repo collects the code for the shiny app to be hosted by a workspace in the DRE [miniapp/](./miniapp) and the docker image used to run a task in the Federated Node [docker/](./docker/)

### Docker image
It's a very simple script added to the rocker/shiny-verse:4.3.2 image, plus some dependencies.

To build it, run
```sh
./build.sh <tag>
```
it will create an image called `ghcr.io/aridhia-open-source/rtest:latest` if `<tag>` arg is not provided.

push it with
```sh
docker push ghcr.io/aridhia-open-source/rtest:latest
```

### Miniapps

#### gitea-fetch
Simple shiny app where it provides some options to customize the repository, branch and file name to fetch from Gitea in a DRE.

If the file exists, then the results will be saved into a file with the same one as the origin, in a path chosen by the user (`~/files` by default).


#### direct-api
Is a simple R script based on `shiny` where a dropdown menu and couple of buttons will be shown to interact with the FN.

#### mapping-fn
Simple R script that given a form for the container registry it will try to map a workspace DB and the registry to a FN.


### Deploying to the workspace

1. Download this GitHub repo as a .zip file.
2. Create a new blank Shiny app in your workspace with a representative name.
3. Navigate to the folder under "files".
4. Delete the `app.R` file from the miniapp folder. Make sure you keep the `.version` file!
5. Upload the .zip file to the miniapp folder.
6. Extract the .zip file. Make sure "Folder name" is blank and "Remove compressed file after extracting" is ticked.
7. Navigate into the unzipped folder.
8. Select all content of the unzipped folder, and move it to the miniapp folder (so, one level up).
9. Delete the now empty unzipped folder.
10. Run the app in your workspace.

For more information visit https://knowledgebase.aridhia.io/article/how-to-upload-your-mini-app/

One additional step might require the whitelisting of the federated node endpoint in the workspace settings.
