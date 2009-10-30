
Factory.sequence(:pid) do |n|
  n
end

Factory.define(:game) do |f|
  f.name "Juggernaut of the Infinite Labyrinth"
  f.pid { Factory.next(:pid) }
end