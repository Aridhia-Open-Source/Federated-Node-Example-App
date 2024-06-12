#!/bin/bash
R_IMAGE=ghcr.io/arihdia-federated-node/rtest:latest

docker build . -t $R_IMAGE
