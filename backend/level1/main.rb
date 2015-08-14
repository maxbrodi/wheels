require "json"
require "date"

# get hash from JSON file

file = File.read('data.json')

data_hash = JSON.parse(file)

cars = data_hash["cars"]
rentals = data_hash["rentals"]

output_array = []

rentals.each do |rental|

  rental_output = {}

  # computing number of days
  start_date = rental["start_date"]
  end_date = rental["end_date"]

  number_of_days = [Date.parse(end_date).mjd - Date.parse(start_date).mjd, 1].max

  # other variables useful for price computation

  # number of km

  number_of_km = rental["distance"]

  # get car for prices

  car = cars[rental["car_id"] - 1]

  # prices of this car

  price_per_day = car["price_per_day"]
  price_per_km = car["price_per_km"]

  # storing in id and price in hash
  rental_output["id"] = rental["id"]
  rental_output["price"] = (number_of_days * price_per_day) + (number_of_km * price_per_km)

  output_array << rental_output

end

# write output to new JSON file

output_hash = { "rentals" => output_array }

File.write('./output.json', output_hash.to_json)

