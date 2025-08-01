FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 5..20) }
    email { Faker::Internet.email }
    password { "password" }
  end
end
