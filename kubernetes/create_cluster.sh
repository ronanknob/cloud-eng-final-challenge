#!/bin/bash

eksctl create cluster -f cluster_config.yaml --profile pos-igti --alb-ingress-access --color=fabulous