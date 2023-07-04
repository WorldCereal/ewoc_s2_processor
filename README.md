# EWoC Sentinel 2 processor docker image

## Use EWoC Sentinel 2 processor docker image

### Retrieve EWoC Sentinel-2 processor docker image

```sh
docker login 643vlk6z.gra7.container-registry.ovh.net -u ${harbor_username}
docker pull 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewoc_s2_processing:${tag_name}
```

#### Generate S2 ARD from S2 product ID

To run the generation of ARD from S1 product ID with upload of data, you need to pass to the docker image a file with some credentials with the option `--env-file /path/to/env.file`. For a test on aws, you need to set: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` with our credentials and `EWOC_CLOUD_PROVIDER=aws`.

:warning: Adapt the `tag_name` to the right one

Example:

```sh
docker run --rm --env-file /local/path/to/env.file 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewoc_s2_processing:${tag_name} s2c -v --data-source aws  S2B_MSIL1C_20190822T105629_N0208_R094_T30SWF_20190822T131655
```
:grey_exclamation: Please consult `ewoc_sen2cor`  for more information on the ewoc_s2 CLI.

## Build EWoC Sentinel 2 processor docker image

To build the docker you need to have the following private python packages close to the Dockerfile:

- ewoc_dag
- ewoc_sen2cor

You can now run the following command to build the docker image:

```sh
docker build --build-arg EWOC_S2_DOCKER_VERSION=$(git describe) --pull --rm -f "Dockerfile" -t ewoc_s2_processing:$(git describe) "."
```

## Push EWoC Sentinel-2 processor docker image

### To OVH Harbor

:warning: Push is done by github-actions! Use these commands only in specific case.

```sh
docker login 643vlk6z.gra7.container-registry.ovh.net -u ${harbor_username}
docker tag ewoc_s2_processing:${tag_name} 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewoc_s2_processing:${tag_name}
docker push 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewoc_s2_processing:${tag_name}
```
