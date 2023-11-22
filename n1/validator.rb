class Validator
  attr_accessor :data, :errors

  def initialize(input_hash)
    @data = input_hash[:data]
    @errors = input_hash[:errors] || []
    @graph_data = []
  end

  def check_all
    validate_presence_of_data
    validate_allowed_characters
    validate_graph_components

    extract_graph_data

    validate_unique_edges
    validate_unique_vertex_numbers_for_vertex_b
    validate_nonzero_edge_numbers
    validate_vertex_numbers_within_range
    validate_edge_numbers_for_vertex_b

    # {errors: @errors, graph:@errors == [] ? @graph_data.delete(:line) : []}
    {errors: @errors, graph: @graph_data}
  end

  private

  def validate_presence_of_data
    if @data.empty?
      @errors << "Отсутствуют данные для проверки."
    end
  end

  def validate_allowed_characters
    @data.each do |item|
      unless item[:data].match?(/^[0-9\s\(\),]+$/)
        @errors << "Строка #{item[:id]} содержит недопустимые символы."
      end
    end
  end

  def validate_graph_components
    @data.each do |item|
      validate_whole_components_in_line(item[:id], item[:data])
    end
  end

  def validate_whole_components_in_line(line_number, line_data)
    components = line_data.scan(/\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\)/)

    unless components.join(", ") == (line_data[-1] == ',' ? line_data[0..-2] : line_data)
      @errors << "Строка #{line_number} содержит некорректные компоненты графа."
    end
  end

  def extract_graph_data
  
    @data.each do |item|
      line_data = item[:data]
      components = line_data.scan(/\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)/)
  
      components.each do |match|
        @graph_data << {
          a: match[0].to_i,
          b: match[1].to_i,
          n: match[2].to_i,
          line: item[:id]
        }
      end

    end
  end

  def validate_unique_edges
    duplicate_edges = @graph_data.group_by { |edge| [edge[:a], edge[:b], edge[:n]] }
                                  .select { |_key, edges| edges.size > 1 }
                                  .map { |_key, edges| edges.map { |edge| edge[:line_number] } }
                                  .flatten
  
    unless duplicate_edges.empty?
      @errors << "Обнаружены повторяющиеся дуги в строках #{duplicate_edges.uniq.join(', ')}"
    end
  end

  def validate_unique_vertex_numbers_for_vertex_b
    grouped_edges = @graph_data.group_by { |edge| edge[:b] }
    
    grouped_edges.each do |vertex, edges|
      duplicate_vertex_numbers = edges.group_by { |edge| edge[:n] }.select { |_key, edges| edges.size > 1 }

      duplicate_vertex_numbers.each do |number, duplicate_edges|
        lines = duplicate_edges.map { |edge| edge[:line] }
        @errors << "Вершина #{vertex}: Дублирующиеся номера вершин в строках #{lines.join(', ')}"
      end
    end
  end
  
  def validate_nonzero_edge_numbers
    zero_edges = @graph_data.select { |edge| edge[:n] == 0 }

    zero_edges.each do |zero_edge|
      @errors << "Вершина #{zero_edge[:b]}: Дуга с номером 0 в строке #{zero_edge[:line]}"
    end
  end

  def validate_vertex_numbers_within_range
    
    total_vertices = @graph_data.flat_map { |edge| [edge[:a], edge[:b]] }.uniq.size

    invalid_vertices = @graph_data.select do |edge|
      edge[:a] > total_vertices || edge[:b] > total_vertices
    end

    invalid_vertices.each do |invalid_vertex|
      @errors << "Неверный номер вершины в строке #{invalid_vertex[:line]}"
    end
  end

  def validate_edge_numbers_for_vertex_b
    grouped_edges = @graph_data.group_by { |edge| edge[:b] }

    grouped_edges.each do |vertex, edges|
      max_edge_number = edges.map { |edge| edge[:n] }.max
      total_incoming_edges = edges.size

      unless max_edge_number == total_incoming_edges
        lines = edges.map { |edge| edge[:line] }
        @errors << "Вершина #{vertex}: Неверные номера дуг в строках #{lines.join(', ')}"
      end
    end
  end

end