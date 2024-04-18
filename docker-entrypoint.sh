#!/bin/sh
set -e
if [ "$RAILS_ENV" != "test" ]; then
    json=$(aws secretsmanager get-secret-value --secret-id $SECRET_ID --region=$AWS_REGION | jq --raw-output '.SecretString')
    echo $json | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" | awk '{ print "export", $1 }' >> /root/.profile
    source /root/.profile
    echo $json
    cat /root/.profile
    env
#    rake db:migrate
else
    rake db:create
    rake db:migrate
fi
exec "$@"