# Overview

Validate a set of taxon names against authority files returned by the TaxonWorks API.

## Implementation

* Use `curl` to download the authority file
* Processing is a Bash script using only `tr` and `awk` (no `sed`)
* The downloaded file is tab-delimited despite the `.csv` endpoint name

## Data

* Hard-coded API base: `https://sfg.taxonworks.org/api/v1/`
* Downloads the full taxon_names table: `https://sfg.taxonworks.org/api/v1/taxon_names.csv?project_token=<PROJECT_TOKEN>`
* Default names input file: `data/names.txt` — one name per line, no author or year
* Downloaded data is cached at `data/cache/<PROJECT_TOKEN>.tab`; if the cache file exists the download is skipped

## Call

```bash
./src/validate.sh <PROJECT_TOKEN>
./src/validate.sh <PROJECT_TOKEN> [names_file]   # optional override for input file
```

## Validator

* Match each input name against the `cached` column
* `cached` is not assumed to be unique:
  * If multiple rows match, prefer the row where `type == Protonym`
  * If exactly one Protonym, use it normally
  * If still ambiguous (multiple Protonyms, or no Protonym), use the first hit and flag with `MULTIPLE HITS` in the output
* Determine validity via `cached_is_valid`
* If invalid, follow `cached_valid_taxon_name_id` to find the valid record and report its `cached` value

## Render

* Write to stdout (user pipes to file)
* Columns are tab-separated; empty cells are truly blank (no literal "nil")
* Columns:
  1. Input name
  2. `id` of the matched record (`no match` if not found)
  3. `cached_valid_taxon_name_id` — present only when `cached_is_valid` is false; blank otherwise
  4. `cached` of the valid record — present only when column 3 is populated; `MULTIPLE HITS` if ambiguous

## Testing

* Use the data in `data/names.txt`
* Target the project with token `c5lh0vgnBGTOQDOSfRYC8g`
