url_toki_mama = \
    https://raw.githubusercontent.com/Discord-Datamining/Discord-Datamining/master/current.js

.DELETE_ON_ERROR:

noop: FRC
	@printf "%s\n" \
	    "jan kepeken li wile ala kepeken ilo \"make\"." \
	    "sina jan kepeken la, o lukin e lipu README."   \
	    "sina jan pali la, o kepeken ilo \"make dev\"." \
	    "[users don't need to run \"make\".]" \
	    "[if you're a user, look at the README.]" \
	    "[if you're a developer, use \"make dev\".]" \
	    >&2

dev: FRC toki_mama_ale.json nimi_lon_toki_ale.txt mama_pi_ante_toki.json mute
clean: FRC
	rm -f toki_mama_ale.json nimi_lon_toki_ale.txt mama_pi_ante_toki.json

watch: FRC
	${MAKE} -s dev
	@rwc -p Makefile i18n/tok.json | xe -s " \
	    clear; \
	    ${MAKE} -s dev \
	        && PAGER=cat git diff ./i18n/tok.json ./mama_pi_ante_toki.json"

# o kama jo e nimi lon toki mama.
# pali kepeken nasin ni li ike mute. :(
# mi wile e ni: ilo Siko, o pana e toki lon nasin JSON taso tawa mi...
# [fetch original language keys.]
# [doing it this way is really bad. :(]
# [I want this: Discord, please give strings to me using JSON only...]
toki_mama_ale.json:
	curl -Lfs ${url_toki_mama} \
	    | sed "s/^\s*//" \
	    | grep -E \
	        -e "^[A-Z][A-Z0-9_]{2,}:\s+['\"].*['\"],$$" \
	        -e "^e\.[A-Z][A-Z0-9_]{2,} = \".*\";$$" \
	    | grep -Ev \
	        -e "['\"] \+ ['\"]?" \
	        -e ": ['\"]hsl\(" \
	        -e ": ['\"]#[a-fA-F0-9]{6}['\"],$$" \
	    | sed -E \
	        -e "/^e\..* = \"([A-Z_]+|[a-z/_-]+|[a-z]+[A-Z][a-z]+)\";/d" \
	        -e "/^e\./ { \
	            s/^e\.//; \
	            s/ = /: /; \
	            s/;$$//; \
	        }" \
	    | sed -E \
	        -e 's/,$$//; s/$$/,/' \
	        -e "s/^(.+): \"/\"\1\": \"/" \
	        -e "/^(.+): '(.*)',?/ { \
	            s/\"/\\\\\"/g; \
	            s/^(.+): '(.*)',?/\"\1\": \"\2\",/; \
	            s/\\\'/'/g \
	        }" \
	        -e '1 { s/^/{/ }; $$ { s/,$$//; s/$$/}/ }' \
	    | jq --indent 4 -S >toki_mama_ale.json

# list of keys existing in both the translation and in original language
nimi_lon_toki_ale.txt: toki_mama_ale.json i18n/tok.json
	jq -r 'keys[]' i18n/tok.json toki_mama_ale.json \
	    | sort \
	    | uniq -d \
	    | sed 's/^/"/; s/$$/"/' > nimi_lon_toki_ale.txt

# list of original language keys used as basis for the translation
mama_pi_ante_toki.json: nimi_lon_toki_ale.txt toki_mama_ale.json
	grep -f nimi_lon_toki_ale.txt toki_mama_ale.json \
	    | sed -E \
	        -e 's/^\s*//' \
	        -e 's/,$$//; s/$$/,/' \
	        -e '1 { s/^/{/ }; $$ { s/,$$//; s/$$/}/ }' \
	    | jq --indent 4 -S > mama_pi_ante_toki.json

# calculate amount of translation completed
mute: FRC i18n/tok.json toki_mama_ale.json mama_pi_ante_toki.json
	@mute_ante=$$(jq -r 'keys[]' i18n/tok.json | wc -l); \
	mute_toki_mama=$$(jq -r 'keys[]' toki_mama_ale.json | wc -l); \
	    printf 'nimi lon ante toki pi ilo Siko: %s\n' "$${mute_ante}"; \
	    printf 'nimi lon toki mama: %s\n' "$${mute_toki_mama}"; \
	    printf 'mute pi ante toki: %s\n' \
	        "$$(printf 'scale=4; (%s/%s)*100.00/1.00\n' "$${mute_ante}" "$${mute_toki_mama}" \
	            | bc \
	            | sed 's/0*$$//g')%"

FRC:
