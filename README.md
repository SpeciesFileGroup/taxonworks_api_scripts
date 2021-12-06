# TaxonWorks API Scripts
Example scripts that reference the [TaxonWorks API](https://api.taxonworks.org).

Code is in `src/`. Organized by language, then API version.

_Note that API version 1 is unstaable, and should be treated as API version 0 semantically._

## Use
* Read the script for an explanation of what its intent is.
* Clone the repository, or download an individual script.
* Set your API tokens (see below).
* Be careful (see below).
* Run the script! 

### API URL 
There is no one Taxonworks, you'll need to use the URL address of your (or an) API. This is the same base URL as your project in TaxonWorks with the API route added, like: `https://sandbox.taxonworks.org/api/v1/`. We reccomend that this address is set as you would for API TOKENS (see below), using the name `TAXONWORKS_API`.

### API TOKENS
Most, but not all API requests require one or two tokens, `&token=` (your user token) and `&project_token=`.
Scripts are encouraged (but nothing is required) to set these tokens using corresponding environment variables:`TAXONWORKS_TOKEN` and `TAXONWORKS_PROJECT_TOKEN`. You can set these in various ways.

#### In a shell configuration
_Any time you open a shell your variables will be set._
See [mac](https://support.apple.com/guide/terminal/use-environment-variables-apd382cc5fa-4f58-4449-b20a-41c53c006f8f/mac), [linux](https://www.linode.com/docs/guides/how-to-set-linux-environment-variables/), and [windows](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables).
#### At runtime 
You can set ENV variables while running the script, for example: `TAXONWORKS_TOKEN=ABC123GHI TAXONWORKS_PROJECT_TOKEN=123DEFQAQ ruby 1234_script_name.rb`
#### In the script
Some scripts have places to include them in the file itself, in a variable, or constant, for example:
```ruby
# Uncomment below and add your TOKEN
# TAXONWORKS_TOKEN='yourtokenhere'
# Uncomment below and add the addresses of the API
# TAXONWORKS_API='https://.../api/v1/'
```

## Be careful
* Running any script may have unintended consequences.
* If you're not sure, ask for help from the community. 
* You alone are resonsible for the outcome of running a script.

## Contributing
* Code goes in `/src/`, organized by language, then API version.
* Filename has no spaces, leads with an issue number if available, and spells out the basic goal, e.g. `1234_get_synonyms_from_user_input.rb` 
* Use a lot of documentation inside the script.
  - Consider including a VERSION in the leading comments of the script
  - Indicate if the script has dependencies that must be loaded
  - Try to link the script to a TaxonWorks, or other, issue-tracker issue that outlines the need for/purpose of the script
* Err on the side of long variable names. The TaxonWorks base code-base best-practice is to spell out all variables, except if they are in loops, condititionals, etc.
* Try to reference ENV variables in the setting API tokens, as opposed to setting them inline. See above.
  - In your script default the ENV variable `TAXONWORKS_API` to `http://127.0.0.1:3000/api/v1/` if it is not set. 
* Try not to commit authentication tokens. It's not the end of the world if you do, they are revokable.
* Consider throttling your requests by sleeping the script for a short time between requests.
* Use a pull request.

## See also

[TaxonWorks homepage](https://taxonworks.org), [TaxonWorks Docs](https://docs.taxonworks.org), [Gitter chat](https://gitter.im/SpeciesFileGroup/taxonworks).
