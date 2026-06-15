# tw_bash_validator

A minimal Bash script that validates a list of taxon names against a [TaxonWorks](https://taxonworks.org) project's authority file via the [TaxonWorks API](https://api.taxonworks.org).

## How it works

1. Downloads the full `taxon_names` table from a TaxonWorks project (tab-delimited despite the `.csv` endpoint) and caches it locally.
2. Reads one name per line from `data/names.txt`.
3. Matches each name against the `cached` column.
4. Determines validity: if `cached_is_valid` is false, follows `cached_valid_taxon_name_id` to report the current valid name.
5. Writes tab-separated results to stdout.

## Requirements

- `bash`
- `curl`
- `awk`
- `tr`

## Usage

You may need to make the script executable before running it:

```bash
chmod +x src/validate.sh
```

```bash
./src/validate.sh <PROJECT_TOKEN>
```

Pipe output to a file:

```bash
./src/validate.sh <PROJECT_TOKEN> > results.tsv
```

An optional second argument overrides the default names file:

```bash
./src/validate.sh <PROJECT_TOKEN> path/to/other_names.txt
```

### Caching

Downloaded data is cached at `data/cache/<PROJECT_TOKEN>.tab`. Subsequent runs reuse the cached file. Delete it to force a fresh download.

## Output columns (tab-separated)

| Column | Content |
|--------|---------|
| 1 | Input name |
| 2 | TaxonWorks `id` of the match (`no match` if not found) |
| 3 | `cached_valid_taxon_name_id` — only present when the match is invalid; blank otherwise |
| 4 | `cached` value of the valid name — only present when column 3 is populated; `MULTIPLE HITS` if ambiguous |

### Multiple matches

When a name matches more than one record:

- A record with `type == Protonym` is preferred.
- If exactly one Protonym exists, it is used normally.
- If ambiguity remains, the first match is used and the valid-name column reads `MULTIPLE HITS`.

## Input format

`data/names.txt` — one name per line, no author or year:

```
Lepidoptera
Alucitidae
Emmelina
```

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
