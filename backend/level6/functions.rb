def compute_transactions(cars, rentals)
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

    bank = {}

    bank["driver"] = price_before_deductible + deductible_fee
    bank["owner"] = price_before_deductible - global_fee
    bank["insurance"] = insurance_fee
    bank["assistance"] = assistance_fee
    bank["drivy"] = drivy_fee + deductible_fee

    bank.each do |stakeholder, money|
      stakeholder_action = {}
      stakeholder_action["who"] = stakeholder
      if stakeholder == "driver"
        stakeholder_action["type"] = "debit"
      else
        stakeholder_action["type"] = "credit"
      end
      stakeholder_action["amount"] = money

      actions << stakeholder_action

    end

    rental_output["actions"] = actions

    output_array << rental_output

  end

  return output_array
end

def change_booking(rentals, rental_modifications)
  new_rentals = []

  rental_modifications.each do |modification|
    rental_to_change = rentals[modification["rental_id"] - 1]

    rental_to_change["start_date"] = modification["start_date"] if modification["start_date"]
    rental_to_change["end_date"] = modification["end_date"] if modification["end_date"]
    rental_to_change["distance"] = modification["distance"] if modification["distance"]

    new_rentals << rental_to_change
  end
  return new_rentals
end

def compute_deltas(old_transactions, new_transactions)
  old_transactions.each do |old_transaction|
  new_transactions.each do |new_transaction|

    if old_transaction["id"] == new_transaction["id"]
      # computing deltas
      old_transaction["actions"].each do |old_action|
        new_transaction["actions"].each do |new_action|
          if old_action["who"] == new_action["who"]
            if new_action["who"] == "driver"
              new_action["amount"] = old_action["amount"] - new_action["amount"]
            else
              new_action["amount"] = new_action["amount"] - old_action["amount"]
            end
            # change debit/credit according to new amount
            if new_action["amount"] < 0
              new_action["type"] = "debit"
            else
              new_action["type"] = "credit"
            end
            new_action["amount"] = new_action["amount"].abs
          end
        end
      end
    new_transaction["rental_id"] = new_transaction["id"]
    end
  end
end

# restart ids for rental modifcations hashes

counter = 1
new_transactions.each do |new_transaction|
  new_transaction["id"] = counter
  counter += 1
end
end
