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

  number_of_days = 1 + Date.parse(end_date).mjd - Date.parse(start_date).mjd

  # other variables useful for price computation

  # number of km

  number_of_km = rental["distance"]

  # get car for prices

  car = cars[rental["car_id"] - 1]

  # computation of price for dates
  default_price = car["price_per_day"]


  if number_of_days == 1
    price_for_dates = default_price
  elsif number_of_days < 4
    price_for_dates = default_price * (1 + ((number_of_days - 1) * 0.9))
  elsif number_of_days < 10
    price_for_dates = default_price * (1 + (3 * 0.9) + ((number_of_days - 3) * 0.7))
  else
    price_for_dates = default_price * (1 + (3 * 0.9) + (6 * 0.7) + ((number_of_days - 10) * 0.5))
  end

  # price per km

  price_per_km = car["price_per_km"]


  # storing in id, price and commission in hash
  rental_output["id"] = rental["id"]
  price_before_deductible = (price_for_dates + (number_of_km * price_per_km)).round

  # deductible option

  deductible_price_per_day = 400

  if rental["deductible_reduction"]
    deductible_fee = deductible_price_per_day * number_of_days
  else
    deductible_fee = 0
  end

  # commisssion


  global_fee = (price_before_deductible * 0.3).round

  insurance_fee = (global_fee * 0.5).round
  assistance_fee = number_of_days * 100
  drivy_fee = global_fee - insurance_fee - assistance_fee



  # actions

  actions = []

  driver_action = {}
  driver_action["who"] = "driver"
  driver_action["type"] = "debit"
  driver_action["amount"] = price_before_deductible + deductible_fee

  actions << driver_action

  owner_action = {}
  owner_action["who"] = "owner"
  owner_action["type"] = "credit"
  owner_action["amount"] = price_before_deductible - global_fee

  actions << owner_action

  insurance_action = {}
  insurance_action["who"] = "insurance"
  insurance_action["type"] = "credit"
  insurance_action["amount"] = insurance_fee

  actions << insurance_action

  assistance_action = {}
  assistance_action["who"] = "assistance"
  assistance_action["type"] = "credit"
  assistance_action["amount"] = assistance_fee

  actions << assistance_action


  drivy_action = {}
  drivy_action["who"] = "drivy"
  drivy_action["type"] = "credit"
  drivy_action["amount"] = drivy_fee + deductible_fee

  actions << drivy_action

  rental_output["actions"] = actions

  output_array << rental_output


end

# write output to new JSON file

output_hash = { "rentals" => output_array }

File.write('./output.json', output_hash.to_json)

