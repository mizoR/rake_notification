require 'active_support/core_ext/string/strip'
require 'breacan'

module RakeNotifier
  class Slack < Base

    START_LABEL   = ":construction: *[START]*"
    SUCCESS_LABEL = ":congratulations: *[SUCCESS]*"
    FAILED_LABEL  = ":x: *[FAILED]*"

    def initialize(token, channel, icon: nil, username: nil, notice_when_fail: false)
      @client = Client.new(token, channel: channel, icon: icon, username: username)
      @notice_when_fail = notice_when_fail
      if @notice_when_fail and !@notice_when_fail.is_a?(String)
        @notice_when_fail = "@channel"
      end
    end

    def started_task(task)
      notice <<-EOS.strip_heredoc
        #{START_LABEL} `$ #{task.reconstructed_command_line}`
        >>> from #{hostname} at #{Time.now} RAILS_ENV=#{rails_env}
      EOS
    end

    def completed_task(task, system_exit)
      success = system_exit.success?
      label = success ? SUCCESS_LABEL : FAILED_LABEL
      at_channel = (success or !@notice_when_fail) ? "" : " #{@notice_when_fail}"
      notice <<-EOS.strip_heredoc
        #{label} `$ #{task.reconstructed_command_line}`#{at_channel}
        >>> exit #{system_exit.status} from #{hostname} at #{Time.now} RAILS_ENV=#{rails_env}
      EOS
    end

    private
    def notice(msg)
      @client.ping(msg)
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
