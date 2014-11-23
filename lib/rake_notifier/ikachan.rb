require 'active_support/core_ext/string/strip'
require 'net/http'
require 'uri'
require 'pathname'

module RakeNotifier
  class Ikachan < Base

    START_LABEL   = "\x02\x0307[START]\x0f"
    SUCCESS_LABEL = "\x02\x0303[SUCCESS]\x0f"
    FAILED_LABEL  = "\x02\x0304[FAILED]\x0f"

    def initialize(url, channel)
      @client = Client.new(url, channel)
    end

    def started_task(task)
      notice <<-EOS.strip_heredoc
        #{START_LABEL} $ #{task.reconstructed_command_line}
        (from #{hostname} at #{Time.now} RAILS_ENV=#{rails_env})
      EOS
    end

    def completed_task(task, system_exit)
      label = system_exit.success? ? SUCCESS_LABEL : FAILED_LABEL
      notice <<-EOS.strip_heredoc
        #{label} $ #{task.reconstructed_command_line}
        (exit #{system_exit.status} from #{hostname} at #{Time.now} RAILS_ENV=#{rails_env})
      EOS
    end

    private

    def notice(message)
      message.each_line {|m| @client.notice m }
    end

    class Client
      def initialize(url, channel)
        @url     = url
        @channel = channel
      end

      def join
        request('/join', {channel: @channel})
      end

      def notice(message)
        join
        request('/notice', {channel: @channel, message: message})
      end

      def uri_for(path = nil)
        uri = URI.parse("#{@url}/#{path}")
        uri.path = Pathname.new(uri.path).cleanpath.to_s
        uri
      end

      def request(path, params)
        begin
          uri = uri_for(path)

          http = Net::HTTP.new(uri.host, uri.port)
          http.open_timeout = http.read_timeout = 10

          req = Net::HTTP::Post.new(uri.path)
          req.form_data = params

          http.request(req)
        rescue StandardError, TimeoutError => e
          $stderr.puts "#{e.class} #{e.message}"
        end
      end
    end
  end
end
