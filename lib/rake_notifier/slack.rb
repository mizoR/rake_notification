require 'active_support/core_ext/string/strip'
require 'slack-notifier'

module RakeNotifier
  class Slack < Base

    START_LABEL   = ":construction: *[START]*"
    SUCCESS_LABEL = ":congratulations: *[SUCCESS]*"
    FAILED_LABEL  = ":x: *[FAILED]*"

    def initialize(webhook_url, channel, icon: nil, username: nil)
      @client = Slack::Notifier.new(webhook_url, channel: channel)
      @client.username = username if username
      @icon = icon
    end
    attr_reader :icon

    def started_task(task)
      notice <<-EOS.strip_heredoc
        #{START_LABEL} `$ #{task.reconstructed_command_line}`
        >>> from #{hostname} at #{Time.now} RAILS_ENV=#{rails_env}
      EOS
    end

    def completed_task(task, system_exit)
      label = system_exit.success? ? SUCCESS_LABEL : FAILED_LABEL
      notice <<-EOS.strip_heredoc
        #{label} `$ #{task.reconstructed_command_line}`
        >>> exit #{system_exit.status} from #{hostname} at #{Time.now} RAILS_ENV=#{rails_env}
      EOS
    end

    private
    def notice(msg)
      if icon
        @client.ping(
          msg,
          icon_url: icon
        )
      else
        @client.ping(msg)
      end
    end
  end
end
