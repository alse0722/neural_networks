require 'json'

class Loader

  def initialize(params = {})
    @init_file_path = params.dig(:init_file_path)
    @graph_file_path = params.dig(:graph_file_path)
    @json_file_path = params.dig(:json_file_path)
    @function_file_path = params.dig(:function_file_path)
    @legend_file_path = params.dig(:legend_file_path)
    @result_file_path = params.dig(:result_file_path)
  end

  def read_data
    result = {data: [], errors: []}

    begin
      File.foreach(@init_file_path).with_index do |line, line_number|
        # Обработка каждой строки файла
        data_hash = {
          id: line_number + 1,
          data: line.chomp
        }
        result[:data] << data_hash
      end
    rescue Errno::ENOENT
      puts "Файл #{@init_file_path} не найден."
    rescue => e
      puts "Произошла ошибка при чтении файла: #{e.message}"
    end

    result
  end

  def read_graph_from_json
    result = {data: [], errors: []}

    begin
      json_data = File.read(@json_file_path)
      graph_data = JSON.parse(json_data, symbolize_names: true)
      # pp graph_data
      # Добавь необходимую обработку или валидацию данных, если нужно

      result[:graph] = graph_data
      puts "Граф успешно прочитан из файла JSON: #{@json_file_path}"
    rescue Errno::ENOENT
      puts "Файл JSON не найден."
    rescue JSON::ParserError => e
      puts "Произошла ошибка при чтении файла JSON: #{e.message}"
    end

    result
  end

  def read_function
    begin
      file_content = File.read(@function_file_path)
      file_content
    rescue StandardError => e
      puts "Error reading the file: #{e.message}"
      nil
    end
  end

  def read_legend
    legend_hash = {}

    begin
      File.foreach(@legend_file_path) do |line|
        parts = line.chomp.split(':')
        key = parts[0].strip.to_i
        value = parts[1].strip
        legend_hash[key] = value
      end
    rescue StandardError => e
      puts "Error reading the legend file: #{e.message}"
      return nil
    end

    legend_hash
  end

  def write_graph_to_file(graph_data)
    begin
      File.open(@graph_file_path, 'w') do |file|
        graph_data.each do |edge|
          file.puts "(#{edge[:a]}, #{edge[:b]}, #{edge[:n]})"
        end
      end
      puts "Граф успешно записан в файл для отрисовки: #{@graph_file_path}"
    rescue => e
      puts "Произошла ошибка при записи в файл: #{e.message}"
    end
  end

  def write_graph_to_json(graph_data)
    begin
      File.open(@json_file_path, 'w') do |file|
        file.puts JSON.pretty_generate(graph_data)
      end
      puts "Граф успешно записан в файл JSON: #{@json_file_path}"
    rescue => e
      puts "Произошла ошибка при записи в файл JSON: #{e.message}"
    end
  end

  def write_function_to_file(function)
    begin
      File.open(@function_file_path, 'w') { |file| file.puts(function) }
      puts "Функция успешно записана в файл: #{@function_file_path}"
    rescue StandardError => e
      puts "Error writing the result to the file: #{e.message}"
    end
  end

  def write_result(result)
    begin
      File.open(@result_file_path, 'w') { |file| file.puts(result) }
      puts "Результат успешно записан в файл: #{@result_file_path}"
    rescue StandardError => e
      puts "Error writing the result to the file: #{e.message}"
    end
  end

end