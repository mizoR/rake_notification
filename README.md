# RakeNotification

[![Build Status](https://img.shields.io/travis/mizoR/rake_notification/master.svg?style=flat)](https://travis-ci.org/mizoR/rake_notification)

Notification of status for rake

## Installation

Add this line to your application's Gemfile:

    gem 'rake_notification'

And then execute:

    $ bundle

### Execution

    $ bundle exec rake_notify awesome_task

### Usage

#### Custom Notifier

```rb
# config/rake_notification.rb

notifier = Object.new.tap do |o|
  def o.started_task(task)
    CustomNotifier.started(task).deliver
  end

  def o.completed_task(task, system_exit)
    if !system_exit.success?
      CustomNotifier.failed(task, system_exit)
    end
  end
end

Rake.application.register_interceptor notifier
Rake.application.register_observer    notifier
```

## Contributing

1. Fork it ( https://github.com/mizoR/rake_notification/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
