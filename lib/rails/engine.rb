module MongoidClientSideEncryption
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.orm :mongoid
      g.test_framework :rspec, fixture: false
      g.assets false
      g.helper false
      g.stylesheets false
      g.javascripts false
    end
  end
end
