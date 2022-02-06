all: FRC toki_mama_ale.json nimi_lon_toki_ale.txt mama_pi_ante_toki.json mute
clean: FRC
	rm -f toki_mama_ale.json nimi_lon_toki_ale.txt mama_pi_ante_toki.json

.DELETE_ON_ERROR:

# fetch original language keys
toki_mama_ale.json:
	curl -Lfs \
	    https://raw.githubusercontent.com/Discord-Datamining/Discord-Datamining/master/current.js \
	    | sed 's/^\s*//' \
	    | grep -E '^[A-Z][A-Z0-9_]{2,}:\s+".*",$$' \
	    | grep -Ev \
	        -e '" \+ "?' \
	        -e ': "hsl\(' \
	        -e ': "#[a-fA-F0-9]{6}",$$' \
	    | sed -E \
	        -e 's/,$$//; s/$$/,/' \
	        -e 's/^(.+): "/"\1": "/' \
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
