#!/bin/sh

set -e
[ "$#" -gt 0 ] || set -- nimi_lon_toki_ale.txt

nimi=$(mktemp)
taso=$(mktemp)

jq -r 'keys[]' i18n/tok.json toki_mama_ale.json >"${nimi}"

sort "${nimi}" \
    | uniq -d \
    | sed 's/^/"/; s/$/"/' \
        >"${taso}"

mv "${taso}" "$1"
rm -f "${nimi}"
