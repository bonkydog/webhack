#! /usr/bin/env ruby

# copycat: a very boring game for testing.

$stdin.sync = $stdout.sync = true

while (move = $stdin.getc.chr) do
  if move == "q"
    $stdout.write "bye!"
    exit 0
  end
  $stdout.write(move)
end