#!/usr/bin/env bash
echo -e "\n===== [$(readlink -f "$0")] =====\n" 1>&2
set -euvx -o pipefail
shopt -s inherit_errexit

: "$1" "$2" "$3" "$4"

readonly SUBSCRIPTION_CODE=${1:?}
readonly RULE_NAME=${2:?}
readonly AGW_NAME=${3:?}
readonly AGW_RG_NAME=${4:?}

pushd "$(dirname "$0")"
trap "popd" EXIT

SUBSCRIPTION_OPTION=$(./build-subscription-option.sh "${SUBSCRIPTION_CODE}")

echo "delete rule"
# shellcheck disable=SC2086
az network application-gateway rule delete \
  ${SUBSCRIPTION_OPTION} \
  --gateway-name "${AGW_NAME}" \
  --resource-group "${AGW_RG_NAME}" \
  --name "${RULE_NAME}" \
  --no-wait || true

