require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SelfBooking
  class Application < Rails::Application
    config.middleware.use I18n::JS::Middleware

    config.active_record.table_name_prefix = 'sb_'

    config.angular_templates.ignore_prefix  = %w(angular/shared/templates/)

    config.autoload_paths += %W(#{config.root}/lib/ #{config.root}/app/navigation_renderers/)
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :en
    config.generators do |g|
      g.orm :active_record
    end
    config.action_dispatch.perform_deep_munge = false
  end
end
