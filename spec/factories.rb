
Factory.define(:user) do |f|
  f.sequence(:login) { |n| "bob#{n}" }
  f.sequence(:email) { |n| "bob#{n}@example.com" }
  f.password "cockatrice"
  f.password_confirmation "cockatrice"
end

