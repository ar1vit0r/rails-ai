FactoryBot.define do
  factory :message do
    role { "MyString" }
    content { "MyText" }
    conversation { nil }
  end
end
