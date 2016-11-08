module Reports::Helpers::Formula

  attr_reader :row

  attr_accessor :chart_from
  attr_accessor :chart_to

  def next
    @row += 1
  end

  def current_row_to_sum_list
    @sum_list << @row
  end

  protected
  def init_report_cell(row)
    @row = row
    @sum_list = []
  end

  def sum_formula_in_range(column, from, to)
    "=SUM(#{column}#{from}:#{column}#{to})"
  end

  def sum_formula_in_list(column)
    "=SUM(#{@sum_list.map { |l| "#{column}#{l}" }.join(',')})"
  end

  def plus(column_a, column_b, row_a, row_b)
    operator column_a, column_b, row_a, row_b, '+'
  end

  def minus(column_a, column_b, row_a, row_b)
    operator column_a, column_b, row_a, row_b, '-'
  end

  def multiply(column_a, column_b, row_a, row_b)
    operator column_a, column_b, row_a, row_b, '*'
  end

  def divide(column_a, column_b, row_a, row_b)
    operator column_a, column_b, row_a, row_b, '/'
  end

  def operator(column_a, column_b, row_a, row_b, o)
    "=#{column_a}#{row_a}#{o}#{column_b}#{row_b}"
  end
end
