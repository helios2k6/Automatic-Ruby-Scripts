require 'json'

class Food
    attr_accessor :name, :protein, :carbs, :fat

    def initialize(name, protein, carbs, fat)
        @name = name
        @protein = protein
        @carbs = carbs
        @fat = fat
    end
end

class Tuple
    attr_accessor :first, :second, :third

    def initialize(first, second, third)
        @first = first
        @second = second
        @third = third
    end

    def < rhs
        return @first < rhs.first &&
            @second < rhs.second &&
            @third < rhs.third
    end

    def > rhs
        return @first > rhs.first &&
            @second > rhs.second &&
            @third > rhs.third
    end

    def <= rhs
        return @first <= rhs.first &&
            @second <= rhs.second &&
            @third <= rhs.third
    end
    
    def >= rhs
        return @first >= rhs.first &&
            @second >= rhs.second &&
            @third >= rhs.third
    end

    def + rhs
        return Tuple.new(@first + rhs.first, @second + rhs.second, @third + rhs.third)
    end

    def - rhs
        return Tuple.new(@first - rhs.first, @second - rhs.second, @third - rhs.second)
    end
end

def decodeFoodFile(file)
    json_file = JSON.parse(IO.read(file))
    json_foods_array = json_file["foods"]
    food_array = []
    json_foods_array.each {|element|
        food_array << Food.new(element["name"], Integer(element["protein"]), Integer(element["carbs"]), Integer(element["fat"]))
    }
    
    return food_array
end

def setMatrixElement(matrix, x, y, z, value)
    if matrix[x] == nil then
        matrix[x] = []
    end

    if matrix[x][y] == nil then
        matrix[x][y] = []
    end

    matrix[x][y][z] = value
end

def max(a, b)
    return a > b ? a : b
end

def determineFoodPlanUsingUnboundedKnapsack(protein_limit, carbs_limit, fat_limit, food_array)
    # All solution matrices use the multidimensional matrix index of M[protein][carbs][fat]
    memoList = []

    for protein in 0..protein_limit
        for carbs in 0..carbs_limit
            for fat in 0..fat_limit
                # Cycle through all items in food food array
                best_tuple = Tuple.new(0, 0, 0)
                for food_index in 0..food_array.length
                    current_food = food_array[food_index]

                    if protein >= current_food.protein && carbs >= current_food.carbs && fat >= current_food.fat then
                        max_protein = max(memoList[protein - current_food.protein][carbs - current_food.carbs][fat - current_food.fat] + )
                    end
                end
            end
        end
    end
end

def distance(x1, x2, y1, y2, z1, z2)
    return Math.sqrt((x1-x2)**2 + (y1-y2)**2 + (z1-z2)**2)
end

def determineFoodPlanUsingPowerSet(protein_limit, carbs_limit, fat_limit, food_array)
    max_subsets = (2**food_array.length) - 1
    
    current_best_subset = nil
    current_best_protein_level = 0
    current_best_carbs_level = 0
    current_best_fat_level = 0
    current_best_distance = distance(current_best_protein_level, protein_limit, current_best_carbs_level, carbs_limit, current_best_fat_level, fat_limit)
    
    for i in 0..max_subsets
        current_subset = []
        for j in 0..food_array.length
            mask = i & (1 << j)
            bit_flag = i & mask
            if bit_flag > 0 then
                current_subset << food_array[j]
            end
        end
        
        current_protein_level = current_subset.reduce(0) {|agg, e| agg + e.protein}
        current_carbs_level = current_subset.reduce(0) {|agg, e| agg + e.carbs}
        current_fat_level = current_subset.reduce(0) {|agg, e| agg + e.fat}
        
        if current_best_subset == nil then
            current_best_subset = current_subset
            current_best_protein_level = current_protein_level
            current_best_carbs_level = current_carbs_level
            current_best_fat_level = current_fat_level
            current_best_distance = distance(current_best_protein_level, protein_limit, current_best_carbs_level, carbs_limit, current_best_fat_level, fat_limit)
        else
            current_distance = distance(current_protein_level, protein_limit, current_carbs_level, carbs_limit, current_fat_level, fat_limit)
            if current_distance < current_best_distance then
                current_best_subset = current_subset
                current_best_protein_level = current_protein_level
                current_best_carbs_level = current_carbs_level
                current_best_fat_level = current_fat_level
                current_best_distance = current_distance
            end
        end
    end
    return current_best_subset
end

def main
    food_array = decodeFoodFile(ARGV[0])
    puts "Calculating food plan using Powerset method"
    best_food_plan = determineFoodPlanUsingPowerSet(Integer(ARGV[1]), Integer(ARGV[2]), Integer(ARGV[3]), food_array)
    puts "=======Food Plan======="
    best_food_plan.each {|food|
        puts "Food #{food.name} |> Protein: #{food.protein} + Carbs #{food.carbs} + Fat #{food.fat}"
    }
end

main