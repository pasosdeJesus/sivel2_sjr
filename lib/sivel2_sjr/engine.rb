require 'sivel2_gen/engine'

module Sivel2Sjr
  class Engine < ::Rails::Engine
    isolate_namespace Sivel2Sjr

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    # Basado en
    # http://pivotallabs.com/leave-your-migrations-in-your-rails-engines/
    initializer :append_migrations do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    # Adaptado de http://guides.rubyonrails.org/engines.html
    config.to_prepare do |app|
#      Dir.glob(Engine.root.to_s + "/app/decorators/**/*_decorator*.rb").each do |c|
#        puts "engine decorator #{c}"
#        require_dependency(c)
#      end
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end
  end
end
