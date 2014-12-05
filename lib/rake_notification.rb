require 'rake'
require 'rake_notifier'

module RakeNotification
  def self.config_path
    './config/rake_notification'
  end

  def reconstructed_command_line
    @reconstructed_command_line ||= "#{File.basename($0)} #{ARGV.join(' ')}"
  end

  def register_observer(observer)
    notification_observers << observer
  end

  def register_interceptor(interceptor)
    notification_interceptors << interceptor
  end

  def top_level
    inform_interceptors rescue nil

    super
  rescue SystemExit => original_error
    inform_observers(original_error) rescue nil
    raise original_error
  rescue Exception => original_error
    inform_observers(SystemExit.new(1, original_error.message)) rescue nil
    raise original_error
  else
    inform_observers rescue nil
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
