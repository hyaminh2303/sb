class CampaignDspDriver
  def initialize(date)
    @date = date.to_date
    $allow_send_message = true if $allow_send_message.nil?
  end

  def sync_data_active_campaign
    active_campaigns = Campaign.active_campaigns(@date).published_campaigns
    active_campaigns.each do |campaign|
      create_campaign_dsp_infos(campaign)
    end
  end

  def create_campaign_dsp_infos(campaign)
    action = 'Update dsp campaign info'
    run_at = Time.now
    begin
      campaign_dsp_info = campaign.order.get_report(start_date = @date, end_date = @date).try(:first)

      return unless campaign_dsp_info

      campaign_dsp_info = {spend: 0, ecpc: 0, ecpm: 0} if campaign_dsp_info.include?('failed')
        
      campaign_info = campaign.campaign_dsp_infos.find_or_initialize_by(date: @date)
      
      campaign_dsp_info.each do |k, v|
        if campaign_info.has_attribute?(k)
          data_type = campaign_info.column_for_attribute(k).type
          parse_data_type = {integer: :to_i, float: :to_f}[data_type]
          campaign_info.send("#{k}=", v.send(parse_data_type)) 
        end
      end
      campaign_info.save
    rescue StandardError => e
      WorkerMailer.error_worker("#{self.class.name}: #{action}", run_at, e, campaign).deliver if $allow_send_message
      $allow_send_message = false
    end
  end
end