

Factory.sequence(:pid) do |n|
  n
end

Factory.sequence(:game) do |n|
  n
end


Factory.define(:game) do |f|
  f.pid { Factory.next(:pid) }
  f.user { Factory(:user) }
end

Factory.define(:user) do |f|
  f.sequence(:login) { |n| "bob#{n}" }
  f.sequence(:email) { |n| "bob#{n}@example.com" }
  f.password "cockatrice"
  f.password_confirmation "cockatrice"
end

