require './loader.rb'
require './validator.rb'
require './formatter.rb'

files = ['2_1.txt', '2_4.txt', '2_9.txt']
custom_path = 'test_files'

files.each do |file|
  @loader = Loader.new({file_path: [custom_path, file].join("/")})
  file_data = @loader.read_data
  # pp file
  # pp file_data
  @validator = Validator.new(file_data)
  graph = @validator.check_all
  # pp graph
  
  graph_file = [custom_path, file.split(".").first + "_graph.txt"].join("/")
  graph_json_file = [custom_path, file.split(".").first + "_json.txt"].join("/")
  pp graph_json_file
  @loader.write_graph_to_file(graph[:graph],graph_file)
  @loader.write_graph_to_json(graph[:graph].each {|e| e.delete(:line)}, graph_json_file)

  pp graph[:errors]
  # `#{['python .\draw.py', graph_file].join(" ")}` #if graph[:errors] == []
  

  if graph[:errors] == []
    graph = @loader.read_graph_from_json(graph_json_file)
    pp graph
    @formatter = Formatter.new(graph[:graph])
    graph_function = @formatter.format_function
    pp graph_function
    `#{['python .\draw.py', graph_file].join(" ")}` #if graph[:errors] == []
  end
end