# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

10.times do |n|
  username = Faker::Name.unique.name
  email = "example-#{n+1}@gmail.com"
  phone = Faker::Number.leading_zero_number(digits: 10)
  address = Faker::Address.full_address
  bio = Faker::Lorem.paragraphs(number: 2).join(" ")
  date_of_birth = Faker::Date.birthday(min_age: 18, max_age: 65)
  password = "password"
  User.create!(username: username, email: email, password: password,
               password_confirmation: password, address: address, date_of_birth: date_of_birth,
               phone_number: phone, bio: bio)
end
