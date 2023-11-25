class Formatter
  def initialize(graph_json)
    @graph_data = graph_json
  end

  def format_function
    sink_vertex = find_sink
    return unless sink_vertex

    function_string = format_vertex(sink_vertex)
    function_string
  end

  private

  def format_vertex(vertex)
    connected_vertices = @graph_data.select { |edge| edge[:b] == vertex }.map { |edge| edge[:a] }
    if connected_vertices.empty?
      "#{vertex}"
    else
      arguments = connected_vertices.map { |v| format_vertex(v) }
      "#{vertex}(#{arguments.join(',')})"
    end
  end

  def find_sink
    all_vertices = @graph_data.flat_map { |edge| [edge[:a], edge[:b]] }
    all_vertices.uniq.each do |vertex|
      return vertex if @graph_data.all? { |edge| edge[:a] != vertex }
    end
    nil
  end
end
