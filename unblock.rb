require_relative 'Board.rb'


b =   Board.new(6, 6)
b.put_block(0, 0, 3 , :horizontal)

b.put_block(0, 3, 2,  :vertical)
b.put_block(1, 2, 2, :vertical)
b.put_block(1, 4, 2, :horizontal)
b.put_block(2, 0, 2, :horizontal, true)
b.put_block(2, 5, 3, :vertical)
b.put_block(3, 0, 3, :vertical)
b.put_block(3, 1,3, :horizontal)
b.put_block(4, 1, 2, :horizontal)
b.put_block(4, 3, 2, :horizontal)
b.put_block(5, 1, 2, :horizontal)
b.put_block(5, 3, 2, :horizontal)

puts b.to_s
puts "---"

puts "moves: #{b.solve.length}"

puts b.solve.join("\n*********\n")