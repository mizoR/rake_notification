require 'spec_helper'

describe RakeNotifier::Ikachan do
  subject { described_class.new(url, channel) }

  let(:url) { 'https://irc.example.com' }
  let(:channel) { 4979 }

  it { should respond_to? :started_task }
  it { should respond_to? :completed_task }
end
