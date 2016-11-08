class Reports::Helpers::AdminFormula

  include Reports::Helpers::Formula

  DEFAULT_COLUMNS = {
      views: 'B',
      clicks: 'C',
      spend: 'E'
  }

  def initialize(init_line, columns_config = nil)
    init_report_cell(init_line)

    @columns = columns_config.nil? ? DEFAULT_COLUMNS : columns_config
  end

  def sum_for_sub_items(column, sub_items_count)
    sum_formula_in_range(@columns[column], @row + 1, @row + sub_items_count)
  end

  def sum_for_grand(column)
    sum_formula_in_list(@columns[column])
  end

  def minus_target(column)
    minus(@columns[column], @columns[column], @row - 1, @row - 2)
  end

  def ctr
    if !@columns[:views].nil? && @columns[:views].to_i != 0
      divide(@columns[:clicks], @columns[:views], @row, @row)
    elsif !@columns[:impressions].nil? && @columns[:impressions].to_i != 0
      divide(@columns[:clicks], @columns[:impressions], @row, @row)
    else
      0
    end
  end

  def ecpm
    "#{divide(@columns[:spend], @columns[:views], @row, @row)}*1000"
  end

  def ecpc
    divide(@columns[:spend], @columns[:clicks], @row, @row)
  end

  def compute_percentage(nominator, denominator, row)
    divide @columns[nominator], @columns[denominator], row, row
  end
end
