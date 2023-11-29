require 'json'

class NeuralNetwork
  def initialize(matrix_file, vector_file)
    @matrix_file = matrix_file
    @vector_file = vector_file
    
    @matrix_json_file = @matrix_file.gsub('matrix', 'matrix_json')
    @result_file = @matrix_file.gsub('matrix', 'result')

    @matrix = nil
    @vector = nil
    @result = nil
  end

  def read_data
    @vector = read_vector(@vector_file)
    @matrix = read_matrix(@matrix_file, @vector.length)
  end

  def check_data
    return unless @matrix && @vector

    # Check vector
    begin
      @vector.map!(&:to_i)
    rescue ArgumentError => e
      puts "Ошибка в векторе: #{e.message}"
      return false
    end

    # Check matrix
    # @matrix.each_with_index do |layer, idx|
    #   layer.each do |neuron|
    #     begin
    #       neuron.map!(&:to_i)
    #     rescue ArgumentError => e
    #       puts "Ошибка в слое #{idx + 1}: #{e.message}"
    #       return false
    #     end

    #     unless neuron.length == @vector.length
    #       puts "Несовпадение числа компонентов в слое #{idx + 1}."
    #       return false
    #     end
    #   end
    # end

    true
  end

  def get_network
    new_matrix = []

    @matrix.each do |layer|
      tmp = []
      layer.each do |neuron|
        value = 0.0
        @vector.each_with_index do |input, i|
          value += neuron[i] * input
        end
        value /= (1 + value.abs)
        tmp << value
      end
      new_matrix << tmp
      @vector = tmp
    end

    @result = new_matrix.last.map(&:to_s).join(" ")
  end

  def save_matrix_to_json
    return unless @matrix

    matrix_data = @matrix.map do |layer|
      layer.map { |neuron| neuron.map(&:to_f) }
    end

    json_data = { matrix: matrix_data }

    begin
      File.open(@matrix_json_file, 'w', encoding: 'utf-8') do |file|
        file.puts JSON.pretty_generate(json_data)
      end
      puts "Матрица успешно сохранена в файле #{@matrix_json_file}."
    rescue StandardError => e
      puts "Ошибка при сохранении матрицы в файл: #{e.message}"
    end
  end

  def save_result_to_file
    begin
      File.open(@result_file, 'w', encoding: 'utf-8') do |file|
        file.puts @result
      end
      puts "Строка успешно сохранена в файле #{@result_file}."
    rescue StandardError => e
      puts "Ошибка при сохранении строки в файл: #{e.message}"
    end
  end

  private

  def read_vector(file_path)
    File.open(file_path, 'r', encoding: 'utf-8') do |file|
      vector_data = file.read.split.map(&:to_i)
      vector_data
    end
  rescue Errno::ENOENT
    puts "Файл #{@vector_file} не найден."
    nil
  end

  def read_matrix(file_path, length)
    begin
      matrix_data = File.open(file_path, 'r', encoding: 'utf-8') do |file|
        file.readlines.map do |line|
          match_data = line.scan(/\[(.*?)\]/)
          next if match_data.empty?

          match_data.map do |inner_values|
            inner_values.first.split.map(&:to_i)
          end
        end.compact
      end

      return nil if matrix_data.empty?

      matrix_data
    rescue Errno::ENOENT
      puts "Файл #{file_path} не найден."
      nil
    end
  end
  
end

