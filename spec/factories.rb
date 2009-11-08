

Factory.sequence(:pid) do |n|
  n
end

Factory.sequence(:game) do |n|
  n
end

Factory.define(:game) do |f|
  f.name {"Game number #{Factory.next(:game)}"}
  f.pid { Factory.next(:pid) }
  f.transcript {"I had an adventure."}
end

Factory.define(:user) do |f|
  f.login "bob"
  f.email "bob@example.com"
  f.password "cockatrice"
  f.password_confirmation "cockatrice"
end