ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'rails/commands/server'

module Rails
    class Server
        alias :original_default_options :default_options
        def default_options
            original_default_options.merge Host: '0.0.0.0', Port: 8080
        end
    end
end

module Rack
    module Handler
        def self.default options = {}
            pick ['torquebox']
        end
    end
end
