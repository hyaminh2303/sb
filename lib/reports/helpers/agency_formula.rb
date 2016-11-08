class Reports::Helpers::AgencyFormula

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
    sum_formula_in_range(@columns[column], 3, @row - 1)
  end

  def sum_for_grand_in_list(column)
    sum_formula_in_list(@columns[column])
  end

  def spend(campaign_type, unit_price_cell = 'I2')
    if !@columns[:views].nil?
      campaign_type == :CPM ? "=#{unit_price_cell}*(#{@columns[:views]}#{@row}/1000)" : "=#{unit_price_cell}*#{@columns[:clicks]}#{@row}"
    elsif !@columns[:impressions].nil?
      campaign_type == :CPM ? "=#{unit_price_cell}*(#{@columns[:impressions]}#{@row}/1000)" : "=#{unit_price_cell}*#{@columns[:clicks]}#{@row}"
    end

  end

  def minus_target(column)
    minus(@columns[column], @columns[column], @row - 1, @row - 2)
  end

  def ctr
    if !@columns[:views].nil?
      divide(@columns[:clicks], @columns[:views], @row, @row)
    elsif !@columns[:impressions].nil?
      divide(@columns[:clicks], @columns[:impressions], @row, @row)
    end
  end
  def compute_percentage(nominator, denominator, row)
    divide @columns[nominator], @columns[denominator], row, row
  end
end
