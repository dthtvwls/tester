require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tester
  class Application < Rails::Application
    config.eager_load = true
    config.log_level = :info
    config.paths['log'] = '/dev/null'
    config.secret_key_base = SecureRandom.hex(64)

    puts Socket.ip_address_list.select(&:ipv4?).map(&:ip_address)
  end
end
