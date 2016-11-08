require 'rails_helper'

class TestModel
  include SelfBooking::Publisher
  attr_accessor :value1, :value2
end

describe SelfBooking::Publisher do
  describe '.on' do
    it 'should subscribe to an event' do
      instance = TestModel.new
      instance.on(:my_event){|model| model.value1 = 1}
      instance.on(:my_event){|model| model.value2 = 2}

      instance.publish(:my_event)

      expect(instance.value1).to eq(1)
      expect(instance.value2).to eq(2)
    end
  end
end