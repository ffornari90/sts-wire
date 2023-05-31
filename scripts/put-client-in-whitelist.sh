#!/bin/bash
cat > $HOME/payload.json <<EOF
{
  "creatorUserId": "admin",
  "clientId": $1,
  "allowedScopes": [
    "email",
    "openid",
    "phone",
    "address",
    "offline_access",
    "eduperson_entitlement",
    "eduperson_scoped_affiliation",
    "profile"
  ]
}
EOF
TOKEN=$(oidc-token docker-admin-ds-119)
curl -s -X POST -H 'Content-type: application/json' -H "Authorization: Bearer $TOKEN" -d @$HOME/payload.json https://ds-119.cr.cnaf.infn.it/api/whitelist | jq '.'
