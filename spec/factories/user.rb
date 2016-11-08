require 'faker'

# This will guess the User class
FactoryGirl.define do
  factory :user, class: User do
    email Faker::Internet.email
    password Faker::Internet.password
    name Faker::Name.name
  end
end