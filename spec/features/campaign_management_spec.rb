require 'rails_helper'

feature 'Campaign management' do
  scenario 'User creates a new campaign' do
    visit '/campaigns/new'

    fill_in 'Name', with: 'My Campaign'
    click_button 'Create Campaign'

    expect(page).to have_text('Campaign was successfully created.')
  end
end