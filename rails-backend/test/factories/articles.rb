FactoryBot.define do
  sequence :slug do |n|
    "slug-#{n}"
  end

  factory :article do
    title { "Some Article" }
    slug
    body { "This is the text of the article" }
    description { "This is the description of the article" }
    user
  end
end
