require './loader.rb'
require './validator.rb'
require './formatter.rb'
require './counter.rb'

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

# @go.ex1
# @go.ex2
@go.ex3