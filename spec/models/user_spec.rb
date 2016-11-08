require 'rails_helper'

RSpec.describe SbUser, :type => :model do
  it 'orders by name' do
    lindeman = SbUser.create!(email: 'lindeman@gmail.com', password: 'password', name: 'Lindeman')
    chelimsky = SbUser.create!(email: 'chelimsky@gmail.com', password: 'password', name: 'Chelimsky')

    expect(SbUser.ordered_by_name).to eq([chelimsky, lindeman])
  end
end