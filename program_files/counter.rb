class Counter
  def initialize(data)
    @function = data[:function]
    @legend = data[:legend]
  end
  
  def evaluate
    # pp @function
    # pp @legend

    replaced_s = replace_numbers_in_string(@function)
    # pp replaced_s

    final_s = replace_functions(replaced_s)
    # pp final_s
    
    result = eval(final_s)
    # pp result

    result
  end

  private

  def replace_numbers_in_string(input_string)
    replaced_string = input_string.gsub(/\d+/) { |match| @legend[match.to_i].to_s }
    return replaced_string
  end

  def replace_functions(input_string)
    input_string.gsub!('+', 'add')
    input_string.gsub!('*', 'mul')
    return input_string
  end

  def add(*args)
    args.sum
  end

  def mul(*args)
    args.reduce(1, :*)
  end

  def exp(arg)
    Math.exp(arg)
  end
end
