module Rsvp
  class Config
    def self.load_configuration
      @@configurations ||= {}
      load './config/rsvp.rb'
    end

    def self.configurations
      @@configurations
    end

    def [](key)
      env = defined?(::Padrino) ? ::Padrino.env : (ENV['RACK_ENV'] || "development").to_sym
      @@configurations[env][key] || @@configurations[:global][key]
    end
  end
end

# Monkeypatching the Kernel. I'm a brave man!
module Kernel
  # Get garasilabs config from 'conf/garasilabs'. Bringing down the g
  def rsvp_config
    @_rsvp_config = @_rsvp_config || Rsvp::Config.new
  end
end
