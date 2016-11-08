namespace :self_booking do
  task remove_duplicate_os: :environment do
    windows_phone = OperatingSystem.find_by(operating_system_code: 'WINDOWS PHONE OS')
    windows_phone.destroy
  end
end