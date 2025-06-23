# UMRT Base Station Image

This repository contains a Docker image used to run the University of Manitoba Robotics Team's base station.
This image is intended to only include runtime dependencies and software used as part of the base station team's workflow.

## How to use

1. Generate a *Personal Access Token* for your GitHub account
    1. In the upper-right corner of any page on GitHub, click your profile photo, then click `Settings`
    2. In the left sidebar, click `Developer settings`
    3. In the left sidebar, under `Personal access tokens`, click `Tokens (classic)`
    4. Click `Generate new token (classic)` at the top of the page
        1. Give your token a nice name, e.g. "UMRT Docker auth token"
        2. Set expiration to a reasonable date sometime between now and your expected graduation
        3. Check `read:packages`, and leave the rest unchecked
        4. Click Generate token
    5. You should now see a bunch of letters/numbers starting with `ghp_`, this is your token
    6. Save the token somewhere safe, once you leave this page you will never be able to see it again
2. Set up Docker authentication
    1. Open a terminal and type, `docker login ghcr.io`
    2. Enter your GitHub username, and instead of password paste your token
    3. You should now be able to download UMRT Docker images!
3. Test by running `docker pull ghcr.io/umroboticsteam/umrt-build` to download the latest image

## Launching the image

An example command is:
`docker run --rm -it --name umrt-base --pull=always ghcr.io/umroboticsteam/umrt-build-dev:main`  
This always checks for and downloads the latest image before starting, which may or may not be the ideal behaviour.
If a specific version is wanted, such as `v0.0.1`, simply change `umrt-build-dev:main` to `umrt-build-dev:v0.0.1`.
