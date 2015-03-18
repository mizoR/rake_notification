require 'spec_helper'

describe RakeNotifier::Slack do
  subject { described_class.new(url, channel, username: username, icon: icon) }

  let(:url) { ' https://hooks.slack.com/services/EXAMPLE/FOO/Bar' }
  let(:channel) { '#rake_notification' }
  let(:username) { nil }
  let(:icon) { nil }
  let(:task) { double(:reconstructed_command_line => 'rake sample') }

  it { is_expected.to respond_to :started_task }
  it { is_expected.to respond_to :completed_task }

  context 'with username' do
    let(:username) { 'Rake bot' }
    it { expect(subject.instance_variable_get(:@client).username).to eq 'Rake bot' }
  end

  context 'posting' do
    before do
      expect(subject.instance_variable_get(:@client)).to receive(:ping).with(an_instance_of(String)).once
    end

    it { subject.started_task(task) }
  end

  context 'posting with icon' do
    let(:icon) { 'http://example.com/icon.png' }

    before do
      expect(subject.instance_variable_get(:@client)).to receive(:ping)
        .with(an_instance_of(String), hash_including(:icon_url => icon))
        .once
    end

    it { subject.started_task(task) }
  end
end
