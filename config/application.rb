require File.expand_path('../boot', __FILE__)
require 'rails'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'

Bundler.require(*Rails.groups)

module Releases
  class Application < Rails::Application

    config.generators do |g|
      g.helper false
      g.view_specs false
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    config.autoload_paths += %W(
                                  #{config.root}/app/reports
                                  #{config.root}/lib
                                  #{config.root}/app/mailers/concerns)

    config.time_zone = 'Eastern Time (US & Canada)'
    config.exceptions_app = self.routes

  end
end
