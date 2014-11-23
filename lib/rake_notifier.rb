require 'socket'

module RakeNotifier
  autoload :Ikachan, File.join(__dir__, 'rake_notifier', 'ikachan')

  class Base
    private

    def hostname
      Socket.gethostname rescue 'Anonymous'
    end

    def rails_env
      ENV['RAILS_ENV'] || 'development'
    end
  end
end
