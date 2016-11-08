module Stats
  class TotalCampaignStats < BaseStats

    def budget_spent
      Hash[Campaign.joins(:daily_tracking_records)
               .select("SUM( CASE WHEN pricing_model = 2 THEN #{Campaign.table_name}.price_cents * #{DailyTrackingRecord.table_name}.clicks ELSE #{Campaign.table_name}.price_cents * #{DailyTrackingRecord.table_name}.views/1000 END ) as budget_spent, #{DailyTrackingRecord.table_name}.date")
               .where(DailyTrackingRecord.table_name.to_sym => {date: @start_date..@end_date})
               .group("#{DailyTrackingRecord.table_name}.date")
               .launched(@user)
               .by_company(@company)
               .search_name(@name_kw).map { |m| [m.date.to_time.to_i*1000, m[@data_type].to_f.round(2)/100] }]
    end

    def field_stats(field)
      Hash[Campaign.joins(:daily_tracking_records)
               .select("SUM(#{field}) AS #{field}, date")
               .where(sb_daily_tracking_records: {date: @start_date..@end_date})
               .group(:date)
               .launched(@user)
               .by_company(@company)
               .search_name(@name_kw).map { |m| [m.date.to_time.to_i*1000, m[@data_type]] if m.date.present? }]
    end
  end
end