class ApplicationDecorator
  attr_accessor :instance

  def initialize(_instance)
    @instance = _instance
  end

  def method_missing(name, *args, &blk)
    @instance.send(name, *args, &blk)
  end
end