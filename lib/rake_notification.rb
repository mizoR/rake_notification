require 'rake'

module RakeNotification
  def self.config_path
    './config/rake_notification'
  end

  refine Rake::Application do
    def reconstructed_command_line
      @reconstructed_command_line ||= "#{File.basename($0)} #{ARGV.join(' ')}"
    end

    def register_observer(observer)
      notification_observers << observer
    end

    def register_interceptor(interceptor)
      notification_interceptors << interceptor
    end

    def run
      inform_interceptors
      super
    rescue SystemExit => e
      inform_observers(e)
      raise e
    else
      inform_observers
    end

    private

    def inform_interceptors
      notification_interceptors.each do |interceptor|
        interceptor.started_task(self)
      end
    end

    def inform_observers(system_exit=SystemExit.new(0))
      notification_observers.each do |observer|
        observer.completed_task(self, system_exit)
      end
    end

    def notification_interceptors
      @notification_interceptors ||= []
    end

    def notification_observers
      @notification_observers ||= []
    end
  end
end
