require_relative 'Block.rb'

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
