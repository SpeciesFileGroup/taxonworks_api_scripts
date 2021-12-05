# Goal: To illustrate a very vanilla (plain) approach to building out a CSV table from 
# set of TaxonWorks API requests.
# Inspiration: https://github.com/SpeciesFileGroup/taxonworks/issues/2665
#
# Requests are build simply by concatenating [Strings][0].
#
# [0][https://en.wikipedia.org/wiki/String_(computer_science)]



# Include some Ruby libraries. All these are standard and require no 
# additional work if Ruby is installed.
# This targeted Ruby 3.x, but it should work all the way back
# to 1.9.
require 'net/http'
require 'net/https'
require 'json'
require 'csv'
require 'byebug' # a debugger

# Find this by looking at your Project in TaxonWorks.  Note that tokens can expire and replaced with new ones.
# TAXONWORKS_PROJECT_TOKEN='a_project_token'

# Find this by editing your Account in TaxonWorks
# TAXONWORKS_TOKEN='your_user_token' 

# TAXONWORKS_API = 'https://sfg.taxonworks.org/api/v1' # An example of pointing at a production server 
TAXONWORKS_API = ENV['TAXONWORKS_API'] || 'http://127.0.0.1:3000/api/v1' # Set the API address to the ENV environment variable or localhost if not set
TAXONWORKS_TOKEN = ENV['TAXONWORKS_TOKEN']
TAXONWORKS_PROJECT_TOKEN = ENV['TAXONWORKS_PROJECT_TOKEN']

# It you want you can comment this, and uncomment above to point to your tokens.
if TAXONWORKS_TOKEN.nil? || TAXONWORKS_PROJECT_TOKEN.nil? || TAXONWORKS_API.nil?
  puts
  puts "TAXONWORKS_TOKEN or TAXONWORKS_PROJECT_TOKEN variable is not set"
  puts "Try running the script this way: TAXONWORKS_TOKEN=your_token TAXONWORKS_PROJECT_TOKEN=your_project_token ruby 2665_tsv_based_on_matrix_with_diverse_metadata.rb"
  puts
  exit
end

# Create a String to append to our requests, we'll re-use this often.  Appending
# all the time is crude, we can be more sophisticated, but it's all the easiest to understand.
# Note the stirng starts with '?', this is the first parameter in the URL, it means
# we need to add this string before our other parameters.
authentication_string = "?token=#{TAXONWORKS_TOKEN}&project_token=#{TAXONWORKS_PROJECT_TOKEN}"
puts 'My authentication string is: ' + authentication_string

# The general pattern we'll use is to create a URI (an object with the address of the request):
# uri = URI(TAXONWORKS_API)
# Then make the request, result will contain a String:
# result = Net::HTTP.get(uri)
# Then parse the result string into JSON
# data = JSON.parse(result)

=begin # A block of comments in Ruby
When coding, it's useful to start with a recipe, or "pseudocode".  It doesn't have to be perfect, you can add to it as you codea.  It helps you organize your strategy, or thoughts. Here's ours for this example:

Goal: Create a CSV file with data both from, and related to rows in an observation matrix in TaxonWorks.  See also "Inspiration" above
Steps:

* Define a list of column headers, this will help us target specific data
*   and keep track of where it goes.  We'll use reference by position
*   in this simple example. More robust/flexible examples that don't depend on order will follow.
* Start a CSV object, in essence an in memory filelist of lists ('C' is not comma, it's "Character")
* Get the list of rows from the matrix
* For each row get (store in memory) that rows:
  * Information about the taxon name linked to that row
  * Information about the type material linked to the taxon name
  * Information about the collection object linked to the type material record
  * Some, but not all, of the cells of data in the matrix
* Add the row to the CSV file
* Go to the next row
* Write the CSV object to a file

=end # End block of comments

# A list of headers. You coula also use headers = ['one', 'two', ...], %w{} does this automagically without the need for commas or quotes. In this example they are user defined.  Order matters in this example.
headers = %w{
  otu_id
  taxon_name_id
  original_genus
  original_species
  original_subspecies
  author
  year
  page
  current_genus
  current_species
  current_subspecies
  current_citation
  taxon_name_status
  catalog_number
  buffered_collecting_event
  buffered_other_labels
  type_of_type
  type_citation
  sex
  higher_grouping  
  published_photos
  remarks
}

# Start a CSV object, this will be used to generate a string to write to a file..

# "\t" = Tab delimited
data = CSV.generate(col_sep: "\t") do |csv|
  csv << headers # Add the headers

  # Get the rows

  # Make a variable with the id of the target observation matrix
  observation_matrix_id = 51

  # The original use case now references a series of matrix columns.  These are identified by "descriptor_id"
  descriptor_ids = [ 
    1409,  # "Taxonomy"/Higher groupings in sample project
    1484,  # Published photos
    1453,  # Remarks
  ]
  
  # Compose the TAXONWORKS_API request string
  row_path = "/observation_matrices/#{observation_matrix_id}#{authentication_string}&extend=rows"
  uri = URI(TAXONWORKS_API + row_path)
  r = Net::HTTP.get(uri)

  # Parse the corresponding JSON into rows
  matrix = JSON.parse(r) 
  # puts rows # uncomment to print the result.  "puts" is useful here. In advanced examples we can style the JSON being printed to the screen

  # binding.pry

  puts "processing #{matrix['rows'].count} rows"

  # Loop the rows
  # matrix['rows'][0..10].each_with_index do |row, i| # To test just a couple rows 
  matrix['rows'].each_with_index do |row, i|
    sleep(1) # Give the API time to rest a little.

    print "row: #{i}\r\r\r\r\r\r"

    c = [] # a variable to contain our row data prior to adding it to the CSV object
   
    # We can code Otus or CollectionObjects (and more soon)
    # This script only works on Otu rows.
    if row['row_object']['base_class'] != 'Otu'
      puts '  !! row is not an OTU, skipping'
      next # Skip to the next row
    end

    otu_id = row['row_object']['object_url'].split('/').last # isolate the otu_id from data like '/otus/123'

    c << otu_id # Add the otu_id as the first cell 

    # Now we just rinse and repeat the pattern for getting a value
    
    # Compose the TAXONWORKS_API request string for an OTU
    otu_path = row['row_object']['object_url'] + authentication_string
    uri = URI(TAXONWORKS_API + otu_path)
    # puts uri
    r = Net::HTTP.get(uri)
    otu = JSON.parse(r) 

    taxon_name_id = otu['taxon_name_id']
    c << taxon_name_id
    
    if taxon_name_id
      # Compose the TAXONWORKS_API request string for some taxon name metadata
      taxon_name_path = "/taxon_names/#{taxon_name_id}/status#{authentication_string}&extend[]=name_elements"
      uri = URI(TAXONWORKS_API + taxon_name_path)
      # puts uri
      r = Net::HTTP.get(uri)
      status = JSON.parse(r) 

      c << status.dig(*%w{elements original_combination genus})
      c << status.dig(*%w{elements original_combination species})
      c << status.dig(*%w{elements original_combination subspecies})
      c << status['author']
      c << status['year'] # status broken
      c << status['pages']
      c << status.dig(*%w{valid_name genus})
      c << status.dig(*%w{valid_name species})
      c << status.dig(*%w{valid_name subspecies})

      if status['is_valid']
        c << status['original_ciation'] 
      else
        c << status.dig(*%w{valid_name original_citation})
      end 

      # Human readable status of the taxon name
      c << status['status']

      # Compose the TAXONWORKS_API request string for the type metadata 
      collection_object_path = "/collection_objects#{authentication_string}&type_specimen_taxon_name_id=#{taxon_name_id}&extend[]=dwc_fields&extend[]=dwc_fields&extend[]=type_material&extend[]=origin_citation"
      uri = URI(TAXONWORKS_API + collection_object_path)
      # puts uri
      r = Net::HTTP.get(uri)
      collection_objects = JSON.parse(r) 

      if collection_objects.count == 1
        co = collection_objects.first
        c << co.dig(*%w{dwc catalogNumber})
        c << co['buffered_collecting_event']
        c << co['buffered_other_labels']

        c << co.dig('type_material')[0].dig('type_type')

        c << co.dig(*%w{dwc origin_citation source cached})

        c << co['dwc']['dwcSex']
      
      else # TEMP - more than one type record
        c << nil 
        c << nil 
        c << nil
        c << nil 
        c << nil 
      end

      descriptor_ids.each do |d|
        observation_path = "/observations#{authentication_string}&descriptor_id=#{d}&otu_id=#{otu_id}&extend[]=character_state"
        uri = URI(TAXONWORKS_API + observation_path)
        # puts uri
        r = Net::HTTP.get(uri)
        observations = JSON.parse(r) 

        v = [] 
        observations.each do |o|
          if o['type'] == 'Observation::Qualitative' 
            v << o['character_state']['name']
          elsif o['type'] == 'Observation::Working'
            v << o['description']
          else
            v << "#{o['type']} is not supported" 
          end
        end

        c << v.join(' | ')
      end

      # Add the row to the csv
      csv << c

    # At this point we jump back to the next row
    end
  end

  puts "done"

  # Stop adding to the CSV
end

# Write the CSV string to file
File.write('2665_data.tsv', data)
puts "Wrote file 266_data.tsv. \n Done."
