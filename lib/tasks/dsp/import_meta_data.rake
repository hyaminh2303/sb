namespace :dsp do
  desc "Generate data for new fields from dsp"
  task :import_meta_data, [:models] => :environment do |t, args|
    args.with_defaults(models: '')

    models = args.models.split ' '

    @dsp_ids = {pocket_math: Platform.pocket_math.id, bidstalk: Platform.bidstalk.id}

    puts "dsp_id: #{@dsp_ids}"

    [
        {
            model: :category,
            dsp:   [:pocket_math, :bidstalk]
        },
        {
            model: :country,
            dsp:   [:pocket_math, :bidstalk]
        },
        {
            model: :interest,
            dsp:   [:bidstalk]
        },
        {
            model: :age_range,
            dsp:   [:bidstalk],
        },
        {
            model: :operating_system,
            dsp:   [:bidstalk],
        },
        {
            model: :timezone,
            dsp:   [:bidstalk]
        },
        {
            model: :campaign_type,
            dsp:   [:bidstalk]
        },
        {
            model: :banner_type,
            dsp:   [:bidstalk]
        },
        {
            model: :gender,
            dsp:   [:bidstalk]
        }
    ].each do |p|
      if models.empty? || (models.present? && models.include?(p[:model].to_s))
        import_meta_data p
      end
    end

  end

  def import_meta_data(params)
    model     = params[:model].to_s.camelize.constantize
    model_map = (params[:model_map] || "#{params[:model].to_s}_dsp_mapping").to_s.camelize.constantize
    dsp       = params[:dsp]
    name      = params[:name] || params[:model].to_s

    puts model.name

    ActiveRecord::Base.connection.execute("TRUNCATE #{name.pluralize};")
    ActiveRecord::Base.connection.execute("TRUNCATE #{name}_dsp_mapping")

    current_dir       = File.dirname(__FILE__)
    first_source_file = "#{current_dir}/#{dsp.first}/normalized/#{name}.csv"

    meta_data = {}
    dsp[1..-1].each do |d|
      source       = "#{current_dir}/#{d}/normalized/#{name}.csv"
      meta_data[d] = CSV.read(source, headers: true)
    end

    c = 0
    CSV.foreach(first_source_file, headers: true) do |row|
      common_row = row.to_hash

      m_common    = model.new(common_row)
      m_common.id = common_row['id']

      unless m_common.save!
        puts "Error at #{model.name}: #{source_file}"
      end

      dsp.each_with_index do |d, i|
        map_row = (i > 0) ? (meta_data[d].find { |h| h['name'].downcase.strip == m_common.name.downcase.strip }).to_hash : common_row

        format_map_row(d, name, map_row)
        m_map                = model_map.new(map_row)
        m_map[:"#{name}_id"] = m_common.id

        unless m_map.save!
          puts "Error at #{model_map.name}: #{source_file}"
        end
      end

      c += 1
    end
    puts "Finished to import #{c} items"
  end

  def format_map_row(dsp, name, map_row)
    map_row[name + '_dsp_id'] = map_row['id'].to_i
    map_row['dsp_id']         = @dsp_ids[dsp]
    map_row.delete('id')
    map_row.delete('name')
    map_row.delete('width') if map_row['width']
    map_row.delete('height') if map_row['height']
    map_row.delete('ad_type') if map_row['ad_type']
    map_row.delete('zone') if map_row['zone']
  end
end
