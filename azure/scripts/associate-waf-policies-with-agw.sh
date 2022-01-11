#!/usr/bin/env bash
echo -e "\n===== [$(readlink -f "$0")] =====\n" 1>&2
set -euvx -o pipefail
shopt -s inherit_errexit

: "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"

readonly SUBSCRIPTION_CODE=${1:?}
readonly ROUTING_PATH=${2:?}
readonly HTTP_SETTING_NAME=${3:?}
readonly BACKEND_POOL_NAME=${4:?}
readonly RULE_NAME=${5:?}
readonly PATH_MAP_NAME=${6:?}
readonly AGW_NAME=${7:?}
readonly AGW_RG_NAME=${8:?}
readonly WAF_NAME=${9:-}
readonly WAF_RG_NAME=${10:-}

pushd "$(dirname "$0")"
trap "popd" EXIT

SUBSCRIPTION_OPTION=$(./build-subscription-option.sh "${SUBSCRIPTION_CODE}")

WAF_OPTION=""
if [ -n "${WAF_NAME}" ]; then
  WAF_POLICY_ID=$(./get-waf-policy-id.sh "${SUBSCRIPTION_CODE}" "${WAF_RG_NAME}" "${WAF_NAME}")
  WAF_OPTION="--waf-policy ${WAF_POLICY_ID}"
fi

echo "create or update path based rule"
az network application-gateway url-path-map rule create \
  ${SUBSCRIPTION_OPTION} \
  --gateway-name "${AGW_NAME}" \
  --resource-group "${AGW_RG_NAME}" \
  --name "${RULE_NAME}" \
  --path-map-name "${PATH_MAP_NAME}" \
  --paths "${ROUTING_PATH}" \
  --address-pool "${BACKEND_POOL_NAME}" \
  --http-settings "${HTTP_SETTING_NAME}" \
  ${WAF_OPTION}
