require_relative 'Board'
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