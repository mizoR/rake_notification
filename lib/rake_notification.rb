require 'rake'
require 'rake_notifier'

module RakeNotification
  def self.config_path
    './config/rake_notification'
  end

  def reconstructed_command_line
    @reconstructed_command_line
  end

  def register_observer(observer)
    notification_observers << observer
  end

  def register_interceptor(interceptor)
    notification_interceptors << interceptor
  end

  def init
    set_reconstructed_command_line

    super
  end

  def top_level
    inform_interceptors rescue nil

    super
  rescue Exception => e
    err = e
    raise
  ensure
    inform_observers(err) rescue nil
  end

  private

  def set_reconstructed_command_line
    @reconstructed_command_line = "#{File.basename($0)} #{ARGV.join(' ')}"
  end

  def inform_interceptors
    notification_interceptors.each do |interceptor|
      interceptor.call(self)
    end
  end

  def inform_observers(err=nil)
    notification_observers.each do |observer|
      observer.call(self, err)
    end
  end

  def notification_interceptors
    @notification_interceptors ||= []
  end

  def notification_observers
    @notification_observers ||= []
  end
end
