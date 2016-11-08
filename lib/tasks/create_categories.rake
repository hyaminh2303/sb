namespace :self_booking do
  task fetch_bidstalk_categories: :environment do
    categories = Bidstalk::MetaData::Client.new('category', 'category').list
    dsp_id = Platform.bidstalk.id
    categories.each do |c|
      category = Category.create(name: c[:name])
      category.category_dsp_mappings.find_or_create_by(dsp_id: dsp_id, category_dsp_id: c[:id])
    end
  end
end