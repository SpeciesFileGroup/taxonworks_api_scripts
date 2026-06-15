#!/usr/bin/env bash

set -e

TOKEN="$1"
NAMES_FILE="${2:-data/names.txt}"
API_URL="https://sfg.taxonworks.org/api/v1/taxon_names.csv?project_token=${TOKEN}"

if [ -z "$TOKEN" ]; then
    echo "Usage: $0 <PROJECT_TOKEN>" >&2
    exit 1
fi

CACHE_DIR="data/cache"
CACHE_FILE="${CACHE_DIR}/${TOKEN}.tab"

mkdir -p "$CACHE_DIR"

if [ ! -f "$CACHE_FILE" ]; then
    curl -s "$API_URL" -o "$CACHE_FILE"
fi

tr -d '\r' < "$CACHE_FILE" | awk -F'\t' -v OFS='\t' -v names_file="$NAMES_FILE" '
BEGIN {
    while ((getline line < names_file) > 0) {
        if (line != "") queries[++nqueries] = line
    }
}
NR == 1 {
    for (i = 1; i <= NF; i++) col[$i] = i
    c_id       = col["id"]
    c_cached   = col["cached"]
    c_valid    = col["cached_is_valid"]
    c_valid_id = col["cached_valid_taxon_name_id"]
    c_type     = col["type"]
    next
}
{
    id       = $c_id
    cached   = $c_cached
    is_valid = $c_valid
    valid_id = $c_valid_id
    type     = $c_type

    row_cached[id]   = cached
    row_valid[id]    = is_valid
    row_valid_id[id] = valid_id
    row_type[id]     = type

    cached_count[cached]++
    cached_ids[cached, cached_count[cached]] = id
}
END {
    for (i = 1; i <= nqueries; i++) {
        q = queries[i]
        if (!(q in cached_count)) {
            print q, "no match", ""
            continue
        }

        count    = cached_count[q]
        multiple = 0

        if (count == 1) {
            id = cached_ids[q, 1]
        } else {
            proto_id    = ""
            proto_count = 0
            for (n = 1; n <= count; n++) {
                if (row_type[cached_ids[q, n]] == "Protonym") {
                    if (proto_id == "") proto_id = cached_ids[q, n]
                    proto_count++
                }
            }
            if (proto_count == 1) {
                id = proto_id
            } else if (proto_count > 1) {
                id = proto_id
                multiple = 1
            } else {
                id = cached_ids[q, 1]
                multiple = 1
            }
        }

        is_valid = row_valid[id]
        valid_id = row_valid_id[id]

        if (is_valid == "false" || is_valid == "0" || is_valid == "f") {
            print q, id, valid_id, (multiple ? "MULTIPLE HITS" : row_cached[valid_id])
        } else {
            print q, id, ""
        }
    }
}'
