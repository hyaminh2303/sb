class Reports::Models::AdminGroup < Reports::Models::AdminCampaign

  attr_reader :group_id
  attr_reader :group_name

  # attr_accessor :data

  def initialize(detail, type = nil)
    super(detail)

    @type = type

    unless @type == :sub
      @group_id = detail.group_id
      @group_name = detail.group_name
    end
  end

  def hash
    _hash = super()

    unless @type == :sub
      _hash[:group_id] = @group_id
      _hash[:group_name] = @group_name
    end

    # unless data.nil?
    #   _hash[:data] = data.map do |d|
    #     d.hash
    #   end
    # end

    _hash
  end
end
