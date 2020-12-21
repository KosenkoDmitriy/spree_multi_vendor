module SpreeMultiVendor
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../../../', __dir__)

      class_option :auto_run_migrations, type: :boolean, default: false
      
      def add_configs
        copy_file 'config/spree_storefront.yml', 'config/spree_storefront.yml'
        copy_file 'app/helpers/spree/vendor_helper.rb', 'app/helpers/spree/vendor_helper.rb'
      end

      def add_images
        copy_file 'vendor/assets/images/spree/frontend/vendor_photo.png', 'vendor/assets/images/spree/frontend/vendor_photo.png'
      end

      def add_javascripts
        copy_file 'vendor/assets/javascripts/spree/frontend/country_state.js', 'vendor/assets/javascripts/spree/frontend/country_state.js'
        # append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/country_state\n"
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_multi_vendor'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
