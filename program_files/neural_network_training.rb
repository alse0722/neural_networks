require 'json'
require './neural_network.rb'

class NotCorrectFileFormatException < StandardError
  def initialize(message)
    super(message)
  end
end

class NeuronValue
  attr_accessor :before, :after

  def initialize(before = 0, after = 0)
    @before = before
    @after = after
  end
end

class TrainingData
  attr_accessor :input, :output

  def initialize(input, output)
    @input = input
    @output = output
  end
end

class Neuronet
  def initialize(params)
    # pp params
    file_name = params[:matrix]
    begin
      file = File.read(file_name)
      raise NotCorrectFileFormatException.new("#{file_name} is not JSON format") unless JSON.parse(file)
    rescue Errno::ENOENT
      puts 'File not found'
      exit(1)
    rescue JSON::ParserError
      puts "#{file_name} is not JSON format"
      exit(2)
    rescue NotCorrectFileFormatException => e
      # puts e.message
      # exit(3)
    end

    matrix_data = JSON.parse(file)
    @count_neuron = []
    @w = []
    matrix_data.each_with_index do |wi_json, i|
      wi = []
      wi_json.each do |wij_json|
        wij = wij_json.map { |val| val.to_f }
        if @count_neuron.empty?
          @count_neuron << wij.size
        elsif @count_neuron.last != wij.size
          raise NotCorrectFileFormatException.new('Было передано некорректное число компонент нейронов в слое! Проверьте входной файл.')
        end
        wi << wij
      end
      @count_neuron << wi.size
      @w << transpose(wi)
    end
  end

  def training(file_selection)
    begin
      puts "Введите число итераций:"
      @n = gets.strip.to_i
      raise 'Число итераций обучения должно быть больше нуля!' if @n.nil? || @n <= 0

      k = 0.01
      selection_file = File.read(file_selection)
      raise NotCorrectFileFormatException.new("#{file_selection} is not JSON format") unless JSON.parse(selection_file)

      training_datas = JSON.parse(selection_file).map do |data|
        input = data['i'].map { |val| val.to_f }
        output = data['o'].map { |val| val.to_f }
        raise NotCorrectFileFormatException.new('Wrong input/output data size in #{file_selection}') if input.size != @count_neuron.first || output.size != @count_neuron.last

        TrainingData.new(input, output)
      end

      raise NotCorrectFileFormatException.new('Not found any training datas') if training_datas.empty?

      idx_training = 0
      (1..n).each do |j|
        neurons_values = []
        current_training_data = training_datas[idx_training]
        input = current_training_data.input.clone
        neurons_values_in_layer = input.map { |d| NeuronValue.new(d, d) }
        neurons_values << neurons_values_in_layer

        result = [input.clone]
        @w.each do |m|
          neurons_values_in_layer = []
          result = mult(result, m)
          result[0].each_with_index do |value, i|
            cur_val = NeuronValue.new(value, activation_function(value))
            result[0][i] = cur_val.after
            neurons_values_in_layer << cur_val
          end
          neurons_values << neurons_values_in_layer
        end

        delta_w = []
        error = []

        i = neurons_values.size - 1
        neurons_values[i].each_with_index do |neuron, m|
          tk = current_training_data.output[m]
          yk = neuron.after
          error << (tk - yk) * activation_function_derivative(neuron.before)
        end

        delta_wi = []
        wi = @w[i - 1]
        wi[0].size.times do |m|
          delta_wij = []
          wi.size.times do |z|
            delta_wij << k * error[m] * neurons_values[i - 1][z].after
          end
          delta_wi << delta_wij
        end
        delta_w << transpose(delta_wi)

        (i - 2).downto(1) do |i|
          wi = @w[i]
          error_in = wi.size.times.map do |m|
            error_inj = wi[m].size.times.inject(0) { |sum, z| sum + error[z] * wi[m][z] }
            error_inj
          end
          error = []
          wi.size.times do |m|
            error << error_in[m] * activation_function_derivative(neurons_values[i][m].before)
          end
          wi = @w[i - 1]
          delta_wi = []
          wi.size.times do |m|
            delta_wij = wi[m].size.times.map do |z|
              k * error[z] * neurons_values[i - 1][m].after
            end
            delta_wi << delta_wij
          end
          delta_w << delta_wi
        end

        @w.size.times do |m|
          wi = @w[m]
          wi_delta = delta_w[@w.size - m - 1]
          wi.each_with_index do |wij, z|
            wij.each_index do |p|
              wij[p] += wi_delta[z][p]
            end
          end
        end

        puts "Итерация #{j}: #{error}"

        idx_training = (idx_training + 1) % training_datas.size
      end
    rescue Errno::ENOENT
      puts 'File not found'
      exit(1)
    rescue JSON::ParserError
      # puts 'Incorrect file data format'
      # exit(2)
    rescue => e
      # puts e.message
      # exit(3)
    end
  end

  def get_result(input, file)
    result = [form_network_training_result(file, @n)]
    if result[0]
      return
    else
      result = [input.clone]
      @w.each do |m|
        result = mult(result, m)
        result[0].each_with_index do |value, i|
          result[0][i] = activation_function(value)
        end
      end
      result[0]
    end
  end

  private

  def activation_function_derivative(x)
    1.0 / ((1 + x.abs) * (1 + x.abs))
  end

  def activation_function(x)
    x / (1 + x.abs)
  end

  def mult(a, b)
    result = Array.new(a.size) { Array.new(b[0].size, 0) }
    a.size.times do |i|
      b[0].size.times do |j|
        result[i][j] = a[i].zip(b.map { |row| row[j] }).map { |x, y| x * y }.sum
      end
    end
    result
  end

  def transpose(mat)
    mat[0].size.times.map do |i|
      mat.size.times.map do |j|
        mat[j][i]
      end
    end
  end
end

