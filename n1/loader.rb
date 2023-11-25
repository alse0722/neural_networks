require 'json'

class Loader

  def initialize(params = {})
    @file_path = params.dig(:file_path)
  end

  def read_data
    result = {data: [], errors: []}

    begin
      File.foreach(@file_path).with_index do |line, line_number|
        # Обработка каждой строки файла
        data_hash = {
          id: line_number + 1,
          data: line.chomp
        }
        result[:data] << data_hash
      end
    rescue Errno::ENOENT
      puts "Файл не найден."
    rescue => e
      puts "Произошла ошибка при чтении файла: #{e.message}"
    end

    result
  end

  def write_graph_to_file(graph_data, output_file_path)
    begin
      File.open(output_file_path, 'w') do |file|
        graph_data.each do |edge|
          file.puts "(#{edge[:a]}, #{edge[:b]}, #{edge[:n]})"
        end
      end
      puts "Граф успешно записан в файл: #{output_file_path}"
    rescue => e
      puts "Произошла ошибка при записи в файл: #{e.message}"
    end
  end

  def write_graph_to_json(graph_data, output_json_file_path)
    begin
      File.open(output_json_file_path, 'w') do |file|
        file.puts JSON.pretty_generate(graph_data)
      end
      puts "Граф успешно записан в файл JSON: #{output_json_file_path}"
    rescue => e
      puts "Произошла ошибка при записи в файл JSON: #{e.message}"
    end
  end

  def read_graph_from_json(json_file_path)
    result = {data: [], errors: []}

    begin
      json_data = File.read(json_file_path)
      graph_data = JSON.parse(json_data, symbolize_names: true)
      pp graph_data
      # Добавь необходимую обработку или валидацию данных, если нужно

      result[:graph] = graph_data
      puts "Граф успешно прочитан из файла JSON: #{json_file_path}"
    rescue Errno::ENOENT
      puts "Файл JSON не найден."
    rescue JSON::ParserError => e
      puts "Произошла ошибка при чтении файла JSON: #{e.message}"
    end

    result
  end

end