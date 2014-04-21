#!/bin/bash

instance=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`

objname=`aws iam list-account-aliases | head -3 | tail -1 | awk -F\" '{print $2}'`
filename=/var/tmp/$objname
echo $filename
echo "{" > $filename
echo "\"account\": \"$objname\"," >> $filename

dval=""

for i in `aws --region us-east-1 ec2 describe-regions | grep RegionName | awk -F\" '{print $4}'`; do
    if [ "$dval" != "" ]; then 
	echo "," >>$filename
    fi
    dval="done"
    echo "\"$i\":" >>$filename
echo "      {" >> $filename
    echo "\"eips\":" >>$filename
    aws --region $i ec2 describe-addresses >>$filename
    echo "," >> $filename
    echo "\"instances\":" >>$filename
    aws --region $i ec2 describe-instances >>$filename
    echo "," >> $filename
    echo "\"elbs\":" >>$filename
    aws --region $i elb describe-load-balancers >>$filename
echo "      }" >> $filename
done
echo "}" >> $filename


aws s3api put-object --acl bucket-owner-full-control --bucket adsk-eis-ea-audit --key ${objname}.txt --body $filename
#aws s3api put-object --bucket adsk-eis-ea-audit --key ${objname}.txt --body $filename

echo "Right now, I would TOTALLY terminate $instance"
