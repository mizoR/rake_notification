require 'rake'
require 'rake_notifier'

module RakeNotification
  def self.config_path
    './config/rake_notification'
  end

  def reconstructed_command_line
    @reconstructed_command_line
  end

  def register_observer(observer=nil, &block)
    if block_given?
      warn "Block is given, so observer(#{observer.inspect}) will be ignored" if observer
      notification_observers << block
    else
      notification_observers << observer
    end
  end

  def register_interceptor(interceptor=nil, &block)
    if block_given?
      warn "Block is given, so interceptor(#{interceptor.inspect}) will be ignored" if interceptor
      notification_interceptors << block
    else
      notification_interceptors << interceptor
    end
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
