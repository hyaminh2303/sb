namespace :self_booking do
  task update_operating_system: :environment do
    a = OperatingSystem.find 11
    a.update_attributes(operating_system_code: "ANDROID", name: "Android")
    b = OperatingSystem.find 12
    b.update_attributes(operating_system_code: "IOS", name: "iOS")

    p "Done"
  end
end