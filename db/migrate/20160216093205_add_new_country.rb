class AddNewCountry < ActiveRecord::Migration
  def change
    Rake::Task['self_booking:import_country'].invoke
  end
end
