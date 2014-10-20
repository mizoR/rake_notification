require 'spec_helper'

describe RakeNotifier::Ikachan::Client do
  subject { client }

  let(:client)  { described_class.new(url, channel) } 
  let(:url)     { 'https://irc.example.com:4649' }
  let(:channel) { '#rake_notification' }

  describe '#uri_for' do
    subject { client.uri_for('/notice') }

    let(:path) { '/notice' }

    its(:to_s) { should eq "#{url}#{path}" } 
  end
end
