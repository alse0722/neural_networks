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

    validate_cycles

    # pp @graph_data
    # {errors: @errors, graph: (@errors == [] ? @graph_data : [])}
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
      line_number = item[:id]
      unless item[:data].match?(/^[0-9\s\(\),]+$/)
        @errors << "Ошибка в строке #{line_number}: строка содержит недопустимые символы."
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
      @errors << "Ошибка в строке #{line_number}: некорректно заданы компоненты графа. Формат: (a, b, n)"
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
                                  .flatten.uniq
  
    duplicate_edges.each do |line_number|
      duplicate_edges_info = @graph_data.select { |edge| [edge[:a], edge[:b], edge[:n]].uniq.size != 3 && edge[:line_number] == line_number }
                                      .map { |edge| "#{edge[:a]}->#{edge[:b]}" }
                                      .join(', ')
      @errors << "Ошибка в строке #{line_number}: повторяющаяся дуга #{duplicate_edges_info}"
    end
  end
  

  def validate_unique_vertex_numbers_for_vertex_b
    grouped_edges = @graph_data.group_by { |edge| [edge[:b], edge[:n]] }
  
    grouped_edges.each do |vertex_and_number, edges|
      next if edges.size <= 1
  
      vertex, number = vertex_and_number
      lines = edges.map { |edge| edge[:line] }
      
      lines.each do |line|
        @errors << "Ошибка в строке #{line}: дуга с номером #{number} в вершину #{vertex} уже существует"
      end
    end
  end
  
  
  def validate_nonzero_edge_numbers
    @graph_data.each do |edge|
      if edge[:n] == 0
        line_number = edge[:line]
        @errors << "Ошибка в строке #{line_number}: вершины 0 быть не может"
      end
    end
  end
  

  def validate_vertex_numbers_within_range
    
    total_vertices = @graph_data.flat_map { |edge| [edge[:a], edge[:b]] }.uniq.size

    invalid_vertices = @graph_data.select do |edge|
      edge[:a] > total_vertices || edge[:b] > total_vertices
    end

    invalid_vertices.each do |invalid_vertex|
      @errors << "Ошибка в строке #{invalid_vertex[:line]}: неправильная нумерация вершин. Номер вершины #{invalid_vertex[:a]} больше количества вершин" if invalid_vertex[:a] > total_vertices
      @errors << "Ошибка в строке #{invalid_vertex[:line]}: неправильная нумерация вершин. Номер вершины #{invalid_vertex[:b]} больше количества вершин" if invalid_vertex[:b] > total_vertices
    end
  end

  def validate_edge_numbers_for_vertex_b
    grouped_edges = @graph_data.group_by { |edge| edge[:b] }
  
    grouped_edges.each do |vertex, edges|
      max_edge_number = edges.map { |edge| edge[:n] }.max
      total_incoming_edges = edges.size
  
      unless max_edge_number == total_incoming_edges
        lines = edges.map { |edge| edge[:line] }
        lines.each do |line_number|
          @errors << "Ошибка в строке #{line_number}: неправильно заданы номера дуг"
        end
      end
    end
  end
  
  def validate_cycles
    visited = Set.new
    stack = Set.new
    all_cycles = Set.new

    @graph_data.each do |start_vertex|
      unless visited.include?(start_vertex[:b])
        detect_cycle(start_vertex[:b], visited, stack, all_cycles)
      end
    end

    all_cycles.each do |cycle|
      lines = cycle.map { |vertex| @graph_data.find { |edge| edge[:b] == vertex }[:line] }
      lines.uniq.each do |line|
        @errors << "Ошибка в строке #{line}: в графе обнаружен цикл #{cycle.join(' -> ')}"
      end
    end
  end

  def detect_cycle(vertex, visited, stack, all_cycles)
    visited.add(vertex)
    stack.add(vertex)

    @graph_data.select { |edge| edge[:a] == vertex }.each do |neighbor|
      if stack.include?(neighbor[:b])
        cycle = stack.to_a.reverse + [neighbor[:b]]
        all_cycles << cycle
      elsif !visited.include?(neighbor[:b])
        detect_cycle(neighbor[:b], visited, stack, all_cycles)
      end
    end

    stack.delete(vertex)
  end
end