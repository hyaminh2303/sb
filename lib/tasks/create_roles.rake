namespace :self_booking do
  task create_roles: :environment do
    %w(admin agency).each do |role|
      Role.find_or_create_by(name: role)
    end
  end
end