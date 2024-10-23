FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :username do |n|
    "person#{n}"
  end

  factory :user do
    email
    username
    password { "qwert1234" }
  end
end
