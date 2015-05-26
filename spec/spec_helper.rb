require 'rubygems'
require 'bundler/setup'
require 'rspec'
Bundler.require(:default, :development)

def file_path( *paths )
  File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', *paths))
end

def public_path( *paths )
  File.expand_path(File.join(File.dirname(__FILE__), 'public', *paths))
end

CarrierWave.root = public_path

NoBrainer.configure do |config|
  config.app_name = 'carrierwave_nobrainer' # dashes not valid in RethinkDB world
  config.environment = 'test'
end

module CarrierWave
  module Test
    module MockFiles
      def stub_file(filename, mime_type=nil, fake_name=nil)
        f = File.open(file_path(filename))
        return f
      end
    end
  end
end

RSpec.configure do |config|
  config.include CarrierWave::Test::MockFiles

  config.before(:each) do
    NoBrainer.purge!
    Dir["#{public_path('uploads')}/*"].each { |path| FileUtils.rm_rf(path) }
  end
end
