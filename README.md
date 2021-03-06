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

#### Ikachan Notifier

```rb
# config/rake_notification.rb

endpoint = 'https://irc.example.com:4979/'
channel  = '#rake_notification'
ikachan  = RakeNotifier::Ikachan.new(endpoint, channel)

Rake.application.register_interceptor ikachan
Rake.application.register_observer    ikachan
```

#### Slack Notifier

```rb
# config/rake_notification.rb

token = 'xoxp-XXXXXXXXXXXXXX...'
channel = '#rake_notification'
slack = RakeNotifier::Slack.new(
  token, channel,
  icon: 'http://www.pubnub.com/docs/img/ruby.png',
  username: 'rake result',
  notice_when_fail: '@here' # false when not to make notice
)

Rake.application.register_interceptor slack
Rake.application.register_observer    slack
```

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
