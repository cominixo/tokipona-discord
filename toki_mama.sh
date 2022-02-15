#!/bin/sh

url="https://raw.githubusercontent.com/Discord-Datamining/Discord-Datamining/master/current.js"
[ "$#" -gt 0 ] || set -- toki_mama_ale.json

mama=$(mktemp)
taso=$(mktemp)
pona=$(mktemp)

set -e

curl -Lfs -o "${mama}" "${url}"

sed "s/^\s*//" "${mama}" \
    | grep -E \
        -e "^[A-Z][A-Z0-9_]{2,}:\s+['\"].*['\"],$" \
        -e "^e\.[A-Z][A-Z0-9_]{2,} = \".*\";$" \
    | grep -Ev \
        -e "['\"] \+ ['\"]?" \
        -e ": ['\"]hsl\(" \
        -e ": ['\"]#[a-fA-F0-9]{6}['\"],$" \
    | sed -E \
        -e "/^e\..* = \"([A-Z_]+|[a-z/_-]+|[a-z]+[A-Z][a-z]+)\";/d" \
        -e "/^e\./ { \
            s/^e\.//; \
            s/ = /: /; \
            s/;$//; \
        }" \
    | sed -E \
        -e 's/,$//; s/$/,/' \
        -e "s/^(.+): \"/\"\1\": \"/" \
        -e "/^(.+): '(.*)',?/ { \
            s/\"/\\\\\"/g; \
            s/^(.+): '(.*)',?/\"\1\": \"\2\",/; \
            s/\\\'/'/g; \
            s/^\"\\\\\"/\"/ \
        }" \
        -e '1 { s/^/{/ }; $ { s/,$//; s/$/}/ }' \
        >"${taso}"

jq --indent 4 -S . <"${taso}" >"${pona}"

mv "${pona}" "$1"
rm -f "${mama}" "${taso}"
