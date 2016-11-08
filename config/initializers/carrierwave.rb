CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => Figaro.env.S3_ACCESS_KEY || '',
      :aws_secret_access_key  => Figaro.env.S3_SECRET_KEY || '',
      :region                 => 'ap-southeast-1'
      #:host                   => 's3.example.com',             # optional, defaults to nil
      #:endpoint               => 'https://s3.example.com:8080' # optional, defaults to nil
  }
  config.fog_directory  = Figaro.env.S3_BUCKET
end
