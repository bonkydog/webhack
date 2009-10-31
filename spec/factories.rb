
Factory.sequence(:pid) do |n|
  n
end

Factory.sequence(:game) do |n|
  n
end

Factory.define(:game) do |f|
  f.name {"Game number #{Factory.next(:game)}"}
  f.pid { Factory.next(:pid) }
end