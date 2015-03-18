require 'spec_helper'

describe RakeNotifier::Slack do
  let(:notifier) { described_class.new(token, channel, username: username, icon: icon) }
  subject { notifier }

  let(:token) { 'xoxo-Example-T0k3N' }
  let(:channel) { '#rake_notification' }
  let(:username) { nil }
  let(:icon) { nil }
  let(:task) { double(:reconstructed_command_line => 'rake sample') }

  it { is_expected.to respond_to :started_task }
  it { is_expected.to respond_to :completed_task }

  context 'variables' do
    subject { notifier.instance_variable_get(:@client) }

    let(:username) { 'Rake bot' }
    let(:icon) { 'http://example.com/icon.png' }

    its(:channel)  { is_expected.to eq '#rake_notification' }
    its(:username) { is_expected.to eq 'Rake bot' }
    its(:icon)     { is_expected.to eq 'http://example.com/icon.png' }
  end

  context 'posting' do
    before do
      expect(subject.instance_variable_get(:@client)).to receive(:ping).with(an_instance_of(String)).once
    end

    it { subject.started_task(task) }
  end

  context 'posting to internal client' do
    let(:username) { 'Rake bot' }
    let(:icon) { 'http://example.com/icon.png' }

    before do
      expect(Breacan).to receive(:chat_post_message)
        .with(hash_including(
          channel: channel,
          icon_url: icon,
          username: username,
          as_user: false,
          text: an_instance_of(String)
        )).once
    end

    it { subject.started_task(task) }
  end
end
