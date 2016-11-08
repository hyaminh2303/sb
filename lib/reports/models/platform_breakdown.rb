class Reports::Models::PlatformBreakdown < Hash
  def initialize(attrs)
    attrs.each do |k, v|
      self[k] = v
    end
  end

  def []=(k, v)
    unless respond_to?(k)
      self.class.send :define_method, k do
        self[k]
      end
    end

    super
  end

  def sum(k, k_sub)
    if defined? self[k_sub] and !self[k_sub].nil?
      self[k] = self[k_sub].sum {|d| d[k]}
    end
  end
end
