require "json"
require "date"
require "./functions.rb"

# get hash from JSON file

file = File.read('data.json')

data_hash = JSON.parse(file)

cars = data_hash["cars"]
rentals = data_hash["rentals"]
rental_modifications = data_hash["rental_modifications"]

transactions = compute_transactions(cars, rentals)

new_rentals = []

rental_modifications.each do |modification|
  rental_to_change = rentals[modification["rental_id"] - 1]

  rental_to_change["start_date"] = modification["start_date"] if modification["start_date"]
  rental_to_change["end_date"] = modification["end_date"] if modification["end_date"]
  rental_to_change["distance"] = modification["distance"] if modification["distance"]

  new_rentals << rental_to_change
end

new_transactions = compute_transactions(cars, new_rentals)


transactions.each do |old_transaction|
  new_transactions.each do |new_transaction|

    if old_transaction["id"] == new_transaction["id"]
      # computing deltas
      old_transaction["actions"].each do |old_action|
        new_transaction["actions"].each do |new_action|
          if old_action["who"] == new_action["who"]
            if new_action["who"] == "driver"
              new_action["amount"] = old_action["amount"] - new_action["amount"]
              p "DRIVER"
            else
              new_action["amount"] = new_action["amount"] - old_action["amount"]
            end
            # change debit/credit according to new amount
            p new_action["amount"]
            if new_action["amount"] < 0
              new_action["type"] = "debit"
            else
              new_action["type"] = "credit"
            end
            new_action["amount"] = new_action["amount"].abs
          end
        end
      end
    end
  end
end

# write output to new JSON file

output_hash = { "rental_modifications" => new_transactions }

File.write('./output.json', output_hash.to_json)

