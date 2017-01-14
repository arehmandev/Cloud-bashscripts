#!/bin/bash

EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"


function route53 {
docker run garland/aws-cli-docker aws route53 list-resource-record-sets --hosted-zone-id $1 | jq .ResourceRecordSets[4].ResourceRecords[0,1,2].Value
}

function getip {
for i in `docker run garland/aws-cli-docker aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $1 --region=$EC2_REGION | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
do
docker run garland/aws-cli-docker aws ec2 describe-instances --instance-ids $i --region=$EC2_REGION | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d '"' -f2 |  xargs printf '%s\n'
done;
}

asgips=$(getip | sort -V)
route53ips=$(route53 | tr -d "\"" | sort -V)

if [[ $asgips != $route53ips ]]; then
  echo "IPs are invalid"
else
  echo "IPs are the same no changes needed"
fi

# Give the hosted zone as an argument e.g. Z4LXVANPVC5RF
