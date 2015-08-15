require "json"
require "date"
require "./functions.rb"

# get hash from JSON file

file = File.read('data.json')

data_hash = JSON.parse(file)

cars = data_hash["cars"]
rentals = data_hash["rentals"]
rental_modifications = data_hash["rental_modifications"]

old_transactions = compute_transactions(cars, rentals)

new_rentals = change_booking(rentals, rental_modifications)

new_transactions = compute_transactions(cars, new_rentals)

rental_modifications = compute_deltas(old_transactions,new_transactions)


# write output to new JSON file

output_hash = { "rental_modifications" => rental_modifications }

File.write('./output.json', output_hash.to_json)

