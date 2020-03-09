#!/bin/bash

set -e

readonly token=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 120"`
readonly region=`curl -H "X-aws-ec2-metadata-token: $token" -v http://169.254.169.254/latest/meta-data//placement/availability-zone | sed -e 's/.$//'`

readonly image=`aws ssm get-parameter --name /ecr/api/latest --region ap-northeast-1 --query 'Parameter.Value' | tr -d '"'`

$(aws ecr get-login --no-include-email --region ${region})
docker run --rm -d -p 80:80 $image
