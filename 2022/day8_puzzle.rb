class TreeChecker
  attr_reader :tree_matrix

  def initialize(tree_matrix)
    @tree_matrix = tree_matrix
  end

  def solutions
    visible_trees = 0
    best_scenic_tree_score = 0

    tree_matrix.each_with_index do |tree_row, row_index|
      tree_row.each_with_index do |tree, col_index|
        visible_trees += 1 if tree_is_visible?(row_index, col_index)

        scenic_tree_score = scenic_tree_score_for(row_index, col_index)
        best_scenic_tree_score = scenic_tree_score if scenic_tree_score > best_scenic_tree_score
      end
    end
    puts "Visible Trees: #{visible_trees}"
    puts "Best Scenic Tree Score: #{best_scenic_tree_score}"
  end

  private
  def tree_is_visible?(row_index, col_index)
    tree = tree_matrix[row_index][col_index].to_i
    
    # NORTH
    return true if (0..row_index - 1).all? { |tree_to_check| tree > tree_matrix[tree_to_check][col_index].to_i }
    
    # EAST
    return true if (col_index + 1..tree_matrix[row_index].size - 1).all? { |tree_to_check| tree > tree_matrix[row_index][tree_to_check].to_i }
    
    # SOUTH
    return true if (row_index + 1..tree_matrix.size - 1).all? { |tree_to_check| tree > tree_matrix[tree_to_check][col_index].to_i }

    # WEST
    return true if (0..col_index - 1).all? { |tree_to_check| tree > tree_matrix[row_index][tree_to_check].to_i }

    return false
  end

  def scenic_tree_score_for(row_index, col_index)
    tree  = tree_matrix[row_index][col_index].to_i
    
    north_score = (0..row_index - 1).reverse_each.slice_when { |tree_to_check| tree <= tree_matrix[tree_to_check][col_index].to_i }.to_a.first&.size || 0
    
    east_score  = (col_index + 1..tree_matrix[row_index].size - 1).slice_when { |tree_to_check| tree <= tree_matrix[row_index][tree_to_check].to_i }.to_a.first&.size || 0
    
    south_score = (row_index + 1..tree_matrix.size - 1).slice_when { |tree_to_check| tree <= tree_matrix[tree_to_check][col_index].to_i }.to_a.first&.size || 0

    west_score  = (0..col_index - 1).reverse_each.slice_when { |tree_to_check| tree <= tree_matrix[row_index][tree_to_check].to_i }.to_a.first&.size || 0
    
    (north_score * east_score * south_score * west_score)
  end
end

tree_matrix = File.read('day8_input.txt').split("\n").map(&:chars)
TreeChecker.new(tree_matrix).solutions