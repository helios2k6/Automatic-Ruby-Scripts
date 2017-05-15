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

def decodeFoodFile(file)
    json_file = JSON.parse(IO.read(file))
    json_foods_array = json_file["foods"]
    food_array = []
    json_foods_array.each {|element|
        food_count = Integer(element["count"]) - 1
        for count in 0..food_count do
            food_array << Food.new(element["name"], Integer(element["protein"]), Integer(element["carbs"]), Integer(element["fat"]))
        end
    }
    
    return food_array
end

def distance(x1, x2, y1, y2, z1, z2)
    return Math.sqrt((x1-x2)**2 + (y1-y2)**2 + (z1-z2)**2)
end

def foodDistance(a, b)
    return Math.sqrt(
        (a.protein - b.protein)**2 + (a.carbs - b.carbs)**2 + (a.fat - b.fat)**2
    )
end

def determineFoodPlanUsingGreedy(protein_limit, carbs_limit, fat_limit, food_array)
    current_protein_allowance = protein_limit
    current_carb_allowance = carbs_limit
    current_fat_allowance = fat_limit

    bag_of_food = []

    # Sort food by largest amount
    sorted_food_array = food_array.sort {|x, y|
        food_distance = foodDistance(x, y)
        # invert since we want decending
        if food_distance < 0 then
            1
        elsif food_distance > 0 then
            -1
        else
            0
        end
    }

    food_array_index = 0
    while (current_protein_allowance > 0 || current_carb_allowance > 0 || current_fat_allowance > 0) && food_array_index < sorted_food_array.length do
        current_food = sorted_food_array[food_array_index]

        prospective_protein_allowance = current_protein_allowance - current_food.protein
        prospective_carb_allowance = current_carb_allowance - current_food.carbs
        prospective_fat_allowance = current_fat_allowance - current_food.fat

        if prospective_protein_allowance >= 0 && prospective_carb_allowance >= 0 && prospective_fat_allowance >= 0 then
            current_protein_allowance = prospective_protein_allowance
            current_carb_allowance = prospective_carb_allowance
            current_fat_allowance = prospective_fat_allowance

            bag_of_food << current_food
        end

        food_array_index += 1
    end

    return bag_of_food
end

def determineFoodPlanUsingPowerSet(protein_limit, carbs_limit, fat_limit, food_array)
    max_subsets = (2**food_array.length) - 1
    
    current_best_subset = nil
    current_best_protein_level = 0
    current_best_carbs_level = 0
    current_best_fat_level = 0
    current_best_distance = distance(current_best_protein_level, protein_limit, current_best_carbs_level, carbs_limit, current_best_fat_level, fat_limit)
    
    for i in 0.upto(max_subsets) do
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

def summarizeFoodArray(food_array)
    puts "=======Food Plan======="
    current_protein_level = 0
    current_carbs_level = 0
    current_fat_level = 0

    sorted_array = food_array.sort {|a, b|
        a.name <=> b.name 
    }

    sorted_array.each {|food|
        puts "#{food.name} |> Protein: #{food.protein} + Carbs #{food.carbs} + Fat #{food.fat}"
        current_protein_level += food.protein
        current_carbs_level += food.carbs
        current_fat_level += food.fat
    }

    puts "==Total=="
    puts "Total Protein: #{current_protein_level}"
    puts "Total Carbs: #{current_carbs_level}"
    puts "Total Fat: #{current_fat_level}"
end

def main
    if ARGV.length == 4 then
        food_array = decodeFoodFile(ARGV[0])
        puts "Calculating food plan using Greedy method"
        best_food_plan = determineFoodPlanUsingGreedy(Integer(ARGV[1]), Integer(ARGV[2]), Integer(ARGV[3]), food_array)
        summarizeFoodArray(best_food_plan)
    else
        puts "Food Plan v0.1"
        puts "Usage: ruby <this script> <food json file> <protein limit> <carbs limit> <fat limit>"
    end
end

main