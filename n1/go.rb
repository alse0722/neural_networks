require './loader.rb'
require './validator.rb'

files = ['1.txt', '2.txt', '10.txt']
custom_path = 'test_files'

files.each do |file|
  @loader = Loader.new({file_path: [custom_path, file].join("/")})
  file_data = @loader.read_data
  pp file
  # pp file_data
  @validator = Validator.new(file_data)
  graph = @validator.check_all
  pp graph
  
  graph_file = [custom_path, file.split(".").first + "_graph.txt"].join("/")
  @loader.write_graph_to_file(graph[:graph],graph_file)
  `#{['python .\draw.py', graph_file].join(" ")}` #if graph[:errors] == []
end