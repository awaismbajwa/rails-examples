FactoryBot.define do
  factory :comment do
    user
    body { "Some text" }
  end
end
