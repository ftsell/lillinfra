#!/usr/bin/env sh
set -eu

TOKEN=$(kubectl --context=ftsell-de -n kubernetes-dashboard create token dashboard-user)

echo "Url:        :  http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo ""
echo "Access Token:  $TOKEN"

kubectl --context=ftsell-de proxy > /dev/null
