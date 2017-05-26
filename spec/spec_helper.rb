ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'pry'
require 'webmock/rspec'
require 'devise'

Dir[Rails.root.join("spec/support/**/*.rb")].each         { |f| require f }
Dir[Rails.root.join("spec/models/concerns/**/*.rb")].each { |f| require f }
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.extend  DbMacros

  config.include Devise::TestHelpers, type: :controller
  config.include ControllerMacros,    type: :controller

  config.include FakerHelpers,        type: :model

  config.infer_spec_type_from_file_location!

  # config.include Rails.application.routes.url_helpers
  # config.order = 'random'
  config.before(:each) do
    WebMock.allow_net_connect!
  end

  # config.before :all do
  #   %x[rake db:clean]
  # end
end
