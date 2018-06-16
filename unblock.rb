
#each tiny square
class Block
    #the orgin is the top left, with x going down and then y going right
    # family is the array of the all the other blocks in teh group

    attr_reader :x, :y, :family,:dir, :board, :special

    def initialize(x, y, family,  dir, board, is_special = false)
        @x = x
        @y = y
        @family = family
        @dir = dir
        @board = board
        @special = is_special
    end

    def head?
        self == @family.first
    end
    
    def tail?
        self == @family.last
    end

    def middle?
        !head? && !tail?
    end

    def length
        @family.length
    end

    def to_s
        if @special
            "@"
        elsif head?
            if @dir == :vertical
                "^"
            else
                "<"
            end
        elsif tail?
            if @dir == :vertical
                "v"
            else
                ">"
            end
        else
            if @dir == :vertical
                "|"
            else 
                "-"
            end
        end
    end

    #direction is either -1 or 1
    def move_single(direction)
        @board.blocks[@x][@y] = nil
        if @dir == :vertical
            @x += direction
            
        else @dir == :horizontal
            @y += direction
        end
        raise "pushed into another" unless @board.blocks[x][y].nil?
        @board.blocks[@x][@y] = self
    end

    def can_group_move(amount)
        @family.first.can_move(amount) || @family.last.can_move(amount)
    end


    #applies to a single block, not teh entire group
    def can_move(amount)
        sign = amount <=> 0
        if @dir == :horizontal
            bounds = [@y + sign, @y + amount]
            @y + amount >= 0 &&
             @y + amount < @board.width &&
              @board.blocks[@x][bounds.min..bounds.max].all?(&:nil?)
        else 
            # p @x + amount < @board.height
            # p @board.blocks[@x + amount][@y].nil?
            # puts @x + amount, @y
            # puts self == @board.blocks[@x][@y]
            bounds = [@x + sign, @x + amount]
            
            @x + amount >= 0 && 
            @x + amount < @board.height && 
            @board.blocks.transpose[@y][bounds.min..bounds.max].all?(&:nil?)
        end
    end

    def move_group(amount)
        if amount > 0
            raise 'bad moving' unless @family.last.can_move(amount)
            @family.reverse_each {|block| block.move_single(amount) }
        elsif amount < 0
            raise "bad moving #{@family.map {|e| e.can_move(amount)}}, #{amount}, info: #{@family.map(&:info)} " unless @family.first.can_move(amount)
            @family.each {|block| block.move_single(amount)}
        end
    end

    def info #for debug
        "x: #{@x} y: #{@y} direction: #{@dir}"
    end

    


end

class Board

    # 2d array
    attr_accessor :blocks

    attr_reader :family_list #just contains the first element of each one,but id on't want to change the anme

    

    def initialize(x, y)
        @blocks = Array.new(x) { Array.new(y)}
        @family_list = []
    end

    def height
        @blocks.length
    end

    def width
        @blocks[0].length
    end

    def to_s
        @blocks.map {|row| row.map {|elem| 
            if elem.nil? 
                 " " 
            else
                elem.to_s 
            end 
        }.join }.join "\n"
    end

    def battle_ship
        @board.blocks.map {|row| row.map {|elem| if elem.nil? then " " else "X" end}.join}.join "\n"
    end

    def ==(other)
        self.to_s == other.to_s
    end

    #always left to right, up down
    def put_block(x, y, length, dir, special = false)
        family = []
        if dir == :horizontal
            return false if y + length  > @blocks[0].length 
            (y...y + length).each do |current_y|
                family << Block.new(x, current_y, family, dir, self, special)
                blocks[x][current_y] = family.last
            end
        elsif dir == :vertical
            return false if x + length > @blocks.length
            (x...x + length).each do |current_x|
                family << Block.new(current_x, y, family, dir, self, special)
                blocks[current_x][y] = family.last
            end
        end
        @family_list << family.first
        true
    end

    def copy 
        other = Board.new(height, width)
        @family_list.each do |head| 
            other.put_block(head.x, head.y, head.length, head.dir, head.special)
        end
        other
    end

    #an array of pairs where each pair is an index of the block and a dir
    def get_moves
        
        @family_list.flat_map do |head| 
            upper_limit = [height, width].max
            ((-upper_limit + 1..-1).to_a + (1...upper_limit).to_a).map do |move_amount|
                [@family_list.index(head), move_amount]
            end
        end.select do |index, amount|
            @family_list[index].can_group_move(amount)
        end
    end

    def possible_boards
        get_moves.map do |index, amount|
            possible = copy
            possible.family_list[index].move_group(amount)
            possible
        end
    end

    def solved?
        special_block = family_list.find {|b| b.special}
        return false if special_block.nil?

        special_block.family.last.y == width - 1 #assuming that its always horizontal
    end

    def solve #returns a lsit of the boards needed to win the game of dota 2
        parent = {to_s => to_s} #contains the strings
        q = possible_boards
        q.each do |board|
            parent[board.to_s] = to_s
        end

        until q.empty?
            current = q.shift 
            if current.solved?
                path = [current.to_s]
                until path.first == to_s
                    path.unshift(parent[path.first])
                    
                end
                return path
            end

            possible = current.possible_boards
            possible.each do |board| 
                str = board.to_s
                unless parent.key? str
                    parent[str] = current.to_s
                    q << board
                end
            end
            
        end
    end


                

        
end


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