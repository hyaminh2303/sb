require 'csv'

namespace :bidstalk do
  desc 'Download meta data and save to csv'
  task download_meta_data: :environment do
    [
        #{name: 'country'},
        #{name: 'category', value_label: :name},
        #{name: 'age', id_label: :age_id, value_label: :age_range, file_name: :age_range},
        #{name: 'interest', value_label: :name},
        #{name: 'os', value_label: :os_name},
        {name: 'timezone', id_label: :timezone_id, value_label: :timezone_offset, others: {zone: :timezone}},
        #{name: 'campaign_types', value_label: :type},
        #{name: 'creative_types', value_label: :creative_type}
    ].each { |params| download_meta_data params }
  end

  def download_meta_data(params = {})
    name       = params[:name]
    id_label   = params[:id_label] || :id
    value_label = params[:value_label] || name.to_sym
    file_name  = params[:file_name] || name
    others = params[:others] || {}

    puts "Download #{name}"

    client = Bidstalk::MetaData::Client.new(name, name.gsub(/_/, '/'))
    meta_list = client.list

    CSV.open(File.dirname(__FILE__) + "/#{file_name}.csv", 'w+') do |csv|
      csv << ['id', "#{file_name}_code", 'name'] + others.keys
      meta_list.each do |d|
        csv << [d[id_label], d[id_label], d[value_label]] + others.map{|k, v| d[v]}
      end
    end

    puts "#{meta_list.size} #{name.pluralize} were saved"
  end
end