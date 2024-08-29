#!/bin/bash
R_IMAGE=ghcr.io/aridhia-open-source/rtest:latest

docker build . -t $R_IMAGE
