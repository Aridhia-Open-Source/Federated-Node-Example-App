#!/bin/bash
R_IMAGE=ghcr.io/aridhia-open-source/rtest:1.1-dev

docker build . -t $R_IMAGE
