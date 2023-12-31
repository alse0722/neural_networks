require './loader.rb'
require './validator.rb'
require './formatter.rb'
require './counter.rb'
require './neural_network.rb'
require './neural_network_training.rb'

class Go
  def initialize(params = {})
    @debug_mode = params.dig(:debug_mode)
  end

  def ex1
    custom_path = '../test_files/n1'
    init_files = ['1.txt', '2.txt', '10.txt']

    init_files.each do |init_file|
      @loader = init_loader(custom_path, init_file)
      pp @loader if @debug_mode

      init_data = @loader.read_data
      pp init_data if @debug_mode

      @validator = Validator.new(init_data)
      graph = @validator.check_all
      pp graph if @debug_mode

      if graph[:errors] == []
        puts "\nИсходный файл #{[custom_path, init_file].join("/")}, задающий граф прошел все проверки!"
        @loader.write_graph_to_file(graph[:graph])
        @loader.write_graph_to_json(graph[:graph].each {|e| e.delete(:line)})
      else
        puts "\nИсходный файл #{[custom_path, init_file].join("/")}, задающий граф не прошел проверки. Ниже представлен список ошибок:"
        puts graph[:errors]
      end
      gets
    end

  end

  def ex2
    custom_path = '../test_files/n2'
    init_files = ['1.txt', '4.txt', '9.txt']

    init_files.each do |init_file|
      @loader = init_loader(custom_path, init_file)
      pp @loader if @debug_mode

      init_data = @loader.read_data
      pp init_data if @debug_mode

      @validator = Validator.new(init_data)
      pp @validator if @debug_mode

      graph = @validator.check_all
      pp graph if @debug_mode

      if graph[:errors] == []
        puts "\nИсходный файл #{[custom_path, init_file].join("/")}, задающий граф прошел все проверки!"
        @loader.write_graph_to_file(graph[:graph])
        @loader.write_graph_to_json(graph[:graph].each {|e| e.delete(:line)})
      else
        puts "\nИсходный файл #{[custom_path, init_file].join("/")}, задающий граф не прошел проверки. Ниже представлен список ошибок:"
        puts graph[:errors]
        next
      end

      json_data = @loader.read_graph_from_json
      pp json_data if @debug_mode

      @formatter = Formatter.new(json_data[:graph])
      pp @formatter if @debug_mode

      graph_function = @formatter.format_function
      pp graph_function if @debug_mode

      @loader.write_function_to_file(graph_function)
      puts "\nГраф задает функцию: #{graph_function}"

      `#{['python .\draw.py', [custom_path, init_file.split(".").first + "_graph.txt"].join("/")].join(" ")}`

    end
  end

  def ex3
    custom_path = '../test_files/n3'
    init_files = ['1.txt', '2.txt', '3.txt']

    init_files.each do |init_file|
      @loader = init_loader(custom_path, init_file)
      pp @loader if @debug_mode

      init_data = @loader.read_data
      pp init_data if @debug_mode

      @validator = Validator.new(init_data)
      pp @validator if @debug_mode

      graph = @validator.check_all
      pp graph if @debug_mode

      if graph[:errors] == []
        puts "\nИсходный файл #{[custom_path, init_file].join("/")}, задающий граф прошел все проверки!"
        @loader.write_graph_to_file(graph[:graph])
        @loader.write_graph_to_json(graph[:graph].each {|e| e.delete(:line)})
      else
        puts "\nИсходный файл #{[custom_path, init_file].join("/")}, задающий граф не прошел проверки. Ниже представлен список ошибок:"
        puts graph[:errors]
        next
      end

      json_data = @loader.read_graph_from_json
      pp json_data if @debug_mode

      @formatter = Formatter.new(json_data[:graph])
      pp @formatter if @debug_mode

      graph_function = @formatter.format_function
      pp graph_function if @debug_mode

      @loader.write_function_to_file(graph_function)
      puts "\nГраф задает функцию: #{graph_function}"

      graph_legend = @loader.read_legend
      puts "\nЛегенда графа задана следующим образом:"
      puts graph_legend

      counter = Counter.new(
        {
          function: graph_function,
          legend: graph_legend
        }
      )

      result = counter.evaluate
      @loader.write_result(result)

      `#{['python .\draw.py', [custom_path, init_file.split(".").first + "_graph.txt"].join("/")].join(" ")}`
    end
  end

  def ex4
    custom_path = '../test_files/n4/'
    init_files = [
      {matrix: custom_path + 'matrix1.txt', vector: custom_path + 'vector1.txt'},
      {matrix: custom_path + 'matrix2.txt', vector: custom_path + 'vector2.txt'},
      {matrix: custom_path + 'matrix3.txt', vector: custom_path + 'vector3.txt'}
    ]

    init_files.each do |files|
      puts "\nРассматриваются матрица #{files[:matrix]} и вектор #{files[:vector]}"

      neural_network = NeuralNetwork.new(files[:matrix], files[:vector])
      
      neural_network.read_data

      # pp neural_network

      if neural_network.check_data
        neural_network.get_network
        neural_network.save_matrix_to_json
        neural_network.save_result_to_file
      end
    end
  end

  def ex5
    custom_path = '../test_files/n5/'
    init_files = [
      {matrix: custom_path + 'matrix1.json', training: custom_path + 'training1.json', result: 'result1.txt'},
      {matrix: custom_path + 'matrix2.json', training: custom_path + 'training2.json', result: 'result2.txt'},
      {matrix: custom_path + 'matrix3.json', training: custom_path + 'training3.json', result: 'result3.txt'}
    ]

    init_files.each do |files|
      puts "\nРассматриваются матрица #{files[:matrix]} и обучающая выборка #{files[:training]}"

      params = files

      neuronet = Neuronet.new(params)
      neuronet_training = neuronet.training(files[:training])
      neuronet.get_result(neuronet_training, files[:result])
    end
  end

  private

  def init_loader(custom_path, init_file)
    Loader.new(
      {
        init_file_path:     [custom_path, init_file].join("/"),
        graph_file_path:    [custom_path, init_file.split(".").first + "_graph.txt"].join("/"),
        json_file_path:     [custom_path, init_file.split(".").first + "_json.txt"].join("/"),
        function_file_path: [custom_path, init_file.split(".").first + "_function.txt"].join("/"),
        legend_file_path:   [custom_path, init_file.split(".").first + "cmd.txt"].join("/"),
        result_file_path:   [custom_path, init_file.split(".").first + "_result.txt"].join("/"),
      }
    )
  end
end

@go = Go.new({debug_mode: false})

# puts "\n\nВыполняется задание 1\n"
# @go.ex1
# gets
# puts "\n\nВыполняется задание 2\n"
# @go.ex2
# gets
# puts "\n\nВыполняется задание 3\n"
# @go.ex3
# gets
# puts "\n\nВыполняется задание 4\n"
# @go.ex4
# gets
puts "\n\nВыполняется задание 5\n"
@go.ex5
gets