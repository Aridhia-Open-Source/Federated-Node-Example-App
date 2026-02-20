#!/bin/bash
TAG=${$1:-latest}

R_IMAGE="ghcr.io/aridhia-open-source/rtest:$TAG"

docker build docker -t $R_IMAGE
