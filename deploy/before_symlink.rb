rails_env = new_resource.environment["RAILS_ENV"]
Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")
execute "rake assets:precompile" do
  cwd release_path
  command "bundle exec rake assets:precompile"
  environment "RAILS_ENV" => rails_env
end
#Chef::Log.info("Starting Indexer...")
#execute "rake indexer RAILS_ENV=#{rails_env}" do
#  cwd release_path
#  command "bundle exec rake indexer RAILS_ENV=#{rails_env}"
#  environment "RAILS_ENV" => rails_env
#end