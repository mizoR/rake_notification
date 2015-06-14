require 'active_support/core_ext/string/strip'
require 'active_support/core_ext/object/try'
require 'breacan'

module RakeNotifier
  module Slack
    class Base < RakeNotifier::Base
      START_LABEL   = ":construction: *[START]*"
      SUCCESS_LABEL = ":congratulations: *[SUCCESS]*"
      FAILED_LABEL  = ":x: *[FAILED]*"

      def initialize(token, channel, icon: nil, username: nil)
        @client = Client.new(token, channel: channel, icon: icon, username: username)
      end

      private
      def notice(msg)
        @client.ping(msg)
      end
    end

    class StartedTask < Base
      def call(task)
        notice <<-EOS.strip_heredoc
        #{START_LABEL} `$ #{task.reconstructed_command_line}`
        >>> from #{hostname} at #{Time.now} RAILS_ENV=#{rails_env}
        EOS
      end
    end

    class CompletedTask < Base
      def call(task, exception)
        is_successfully = exception.try(:success?) || exception.nil?
        failed_status   = exception.try(:status) || 1
        label, status   = is_successfully ? [SUCCESS_LABEL, 0] : [FAILED_LABEL, failed_status]

        notice <<-EOS.strip_heredoc
        #{label} `$ #{task.reconstructed_command_line}`
        >>> exit #{status} from #{hostname} at #{Time.now} RAILS_ENV=#{rails_env}
        EOS
      end
    end

    class Client
      def initialize(token, channel: '#test', icon: nil, username: nil)
        Breacan.access_token = @token = token
        @channel = channel
        @icon = icon
        @username = username
      end
      attr_accessor :token, :channel, :icon, :username

      def args_to_post(msg)
        arg = {
          channel: channel,
          text: msg,
          as_user: false,
        }
        arg[icon_key(icon)] = icon if icon
        arg[:username] = username if username
        arg
      end

      def ping(msg)
        Breacan.chat_post_message(args_to_post(msg))
      end

      private
      def icon_key(icon_info)
        case icon_info
        when /^https?:\/\//
          :icon_url
        when /^:.+:$/
          :icon_emoji
        else
          raise "May be invalid icon format: #{icon_info}"
        end
      end
    end
  end
end
