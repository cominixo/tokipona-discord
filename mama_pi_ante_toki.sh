#!/bin/sh

set -e
[ "$#" -gt 0 ] || set -- mama_pi_ante_toki.json

nimi_taso=$(mktemp)
taso=$(mktemp)
pona=$(mktemp)

grep -f nimi_taso_lon_toki_ale.txt toki_mama_ale.json >"${nimi_taso}"

sed \
    -E \
    -e 's/^\s*//' \
    -e 's/,$//; s/$/,/' \
    -e '1 { s/^/{/ }; $ { s/,$//; s/$/}/ }' \
    <"${nimi_taso}" \
    >"${taso}"

jq --indent 4 -S <"${taso}" >"${pona}"
mv "${pona}" "$1"
rm -f "${nimi_taso}" "${taso}"
