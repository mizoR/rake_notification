require 'spec_helper'

describe RakeNotifier::Ikachan do
  subject { described_class.new(url, channel) }

  let(:url) { 'https://irc.example.com' }
  let(:channel) { 4979 }

  it { is_expected.to respond_to :started_task }
  it { is_expected.to respond_to :completed_task }
end
