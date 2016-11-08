namespace :self_booking do
  desc "Add other to Operating System"
  task add_other: :environment do
    other = OperatingSystem.find_by_operating_system_code("OTHERS")
    unless other
      other = OperatingSystem.create(operating_system_code: "OTHERS", name: "Others")
    end
  end
end