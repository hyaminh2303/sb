class Reports::Models::AgencyGroup < Reports::Models::AgencyCampaign

  attr_reader :group_id
  attr_reader :group_name

  attr_accessor :data

  def initialize(detail, campaign, type = nil)
    super(detail, campaign)

    @type = type

    unless @type == :sub
      @group_id = detail.group_id
      @group_name = detail.group_name
    end
  end

  def hash
    _hash = super()

    unless @type == :sub
      _hash = _hash.merge({
                              group_id: @group_id,
                              group_name: @group_name
                          })
    end

    _hash
  end
end
