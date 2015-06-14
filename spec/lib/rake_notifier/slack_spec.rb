require 'spec_helper'

describe RakeNotifier::Slack do
  let(:notifier) { notifier_class.new(token, channel, username: username, icon: icon) }
  subject { notifier }

  let(:token) { 'xoxo-Example-T0k3N' }
  let(:channel) { '#rake_notification' }
  let(:username) { nil }
  let(:icon) { nil }
  let(:task) { double(:reconstructed_command_line => 'rake sample') }

  describe do
    subject { notifiers }

    let(:notifiers) { described_class.create_notifiers(token, channel, username: username, icon: icon) }

    its(:size)  { is_expected.to eq 2 }
    its(:first) { is_expected.to be_instance_of(described_class::StartedTask) }
    its(:last)  { is_expected.to be_instance_of(described_class::CompletedTask) }
  end

  shared_examples_for 'a slack client' do
    context 'variables' do
      subject { client }

      let(:client) { notifier.instance_variable_get(:@client) }

      let(:username) { 'Rake bot' }
      let(:icon) { 'http://example.com/icon.png' }

      its(:channel)  { is_expected.to eq '#rake_notification' }
      its(:username) { is_expected.to eq 'Rake bot' }
      its(:icon)     { is_expected.to eq 'http://example.com/icon.png' }
    end
  end

  shared_examples_for 'started task notification' do
    let(:client) { notifier.instance_variable_get(:@client) }

    context 'posting' do
      before do
        expect(client).to receive(:ping).with(an_instance_of(String)).once
      end

      it { notifier.call(task) }
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

      it { notifier.call(task) }
    end
  end

  describe 'StartedTask' do
    let(:notifier_class) { described_class.const_get 'StartedTask' }
    it { is_expected.to respond_to :call }
    it_behaves_like 'a slack client'
    it_behaves_like 'started task notification'
  end

  describe 'CompletedTask' do
    let(:notifier_class) { described_class.const_get 'CompletedTask' }
    it { is_expected.to respond_to :call }
    it_behaves_like 'a slack client'
  end
end
