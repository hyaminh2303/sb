namespace :dsp do
  desc 'Compare meta data of all dsp'
  task compare_meta_data: :environment do
    [:country, :category].each { |n| compare_meta_data n }
  end

  def compare_meta_data(name)
    puts "Compare #{name.to_s.pluralize}"

    current_dir = File.dirname(__FILE__)

    data = {}
    data_name = {}

    [:pocket_math, :bidstalk].each do |dsp|
      source =  "#{current_dir}/#{dsp}/#{name}.csv"
      data[dsp] = CSV.read(source, headers: true)
      data_name[dsp] = data[dsp].each.map { |r| r['name'].strip.downcase }
    end

    intersection_data = data_name.values.inject(:&)
    difference_data = data_name.values.inject(:|) - intersection_data

    CSV.open(File.dirname(__FILE__) + "/#{name}.csv", 'w+') do |csv|
      csv << ['id', "#{name}_code", 'name']
      data[:pocket_math].each do |d|
        if intersection_data.include?(d['name'].strip.downcase)
          csv << d
        else
          d['name'] += ' XX'
          csv << d
        end
      end
    end

    puts "Intersection Data size: #{intersection_data.size}"
    puts "Total difference data size: #{difference_data.size}"
  end
end