module Stats
  class CampaignStats < BaseStats

    #
    # Query budget data for display in Grid on dashboard
    # pricing == 1 => CPM
    # pricing == 2 => CPC
    def budget_spent
      Hash[Campaign.joins(:daily_tracking_records)
               .select("SUM( CASE WHEN pricing_model = 2 THEN #{Campaign.table_name}.price_cents * #{DailyTrackingRecord.table_name}.clicks ELSE #{Campaign.table_name}.price_cents * #{DailyTrackingRecord.table_name}.views/1000 END ) as budget_spent, #{DailyTrackingRecord.table_name}.date")
               .where(DailyTrackingRecord.table_name.to_sym => {campaign_id: @campaign_id, date: @start_date..@end_date})
               .group("#{DailyTrackingRecord.table_name}.date")
               .launched(@user).by_company(@company).map { |m| [m.date.to_time.to_i*1000, m[@data_type].to_f.round(2)/100] }]
    end

    #
    # Query views and clicks data for display in Grid on dashboard
    # @param [String] field Field name need to get stat, include `views` and `clicks`
    # @return [Hash]
    def field_stats(field)
      Hash[Campaign.joins(:daily_tracking_records)
               .select("SUM(#{field}) AS #{field}, date")
               .where(sb_daily_tracking_records: {campaign_id: @campaign_id, date: @start_date..@end_date})
               .group(:date).launched(@user).by_company(@company).map { |m| [m.date.to_time.to_i*1000, m[@data_type]] if m.date.present? }]
    end
  end
end