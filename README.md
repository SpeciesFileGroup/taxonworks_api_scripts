# TaxonWorks Api Scripts

Example scripts that reference the [TaxonWorks API](https://api.taxonworks.org).

Code is in `src/`. Organized by language, then API version.

Note that API version 1 is unstaable, and should be treated as API version 0 semantically.

## Contributing
* Code goes in src, organized by language, then API versions. 
* Use a lot of ocumentation inside the script.
  - Consider including a VERSION in the leading comments of the script
  - Indicate if the script has dependencies that must be loaded
  - Try to link the scvript to a TaxonWorks, or other, issue-tracker issue that outlines the need for/purpose of the script
* Try not to commit authentication tokens.  It's not the end of the world if you do, they are revokable.
* Use a pull request

## See also

[TaxonWorks homepage](https://taxonworks.org), [TaxonWorks Docs](https://docs.taxonworks.org), [Gitter chat](https://gitter.im/SpeciesFileGroup/taxonworks).
