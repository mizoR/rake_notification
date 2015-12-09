require 'spec_helper'

describe RakeNotifier::Slack do
  let(:notifier) { described_class.new(token, channel, username: username, icon: icon, notice_when_fail: notice_when_fail) }
  subject { notifier }

  let(:token) { 'xoxo-Example-T0k3N' }
  let(:channel) { '#rake_notification' }
  let(:username) { nil }
  let(:icon) { nil }
  let(:notice_when_fail) { false }
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

  context 'messages to post' do
    now = Time.now
    let(:time_now) { now }

    before do
      allow(Time).to receive(:now) { time_now }
      allow(subject).to receive(:hostname) { 'rake.example.com' }

      allow(subject).to receive(:notice) do |arg|
        @string_to_be_posted = arg
      end
    end

    describe 'on start' do
      it {
        subject.started_task(task)
        expect(@string_to_be_posted).to eq(<<-EOS)
:construction: *[START]* `$ rake sample`
>>> from rake.example.com at #{time_now.to_s} RAILS_ENV=development
        EOS
      }
    end

    describe 'on success' do
      let(:exit_status) { double(:success? => true, :status => 0) }

      it {
        subject.completed_task(task, exit_status)
        expect(@string_to_be_posted).to eq(<<-EOS)
:congratulations: *[SUCCESS]* `$ rake sample`
>>> exit 0 from rake.example.com at #{time_now.to_s} RAILS_ENV=development
        EOS
      }
    end

    describe 'on failed' do
      let(:exit_status) { double(:success? => false, :status => 127) }

      it {
        subject.completed_task(task, exit_status)
        expect(@string_to_be_posted).to eq(<<-EOS)
:x: *[FAILED]* `$ rake sample`
>>> exit 127 from rake.example.com at #{time_now.to_s} RAILS_ENV=development
        EOS
      }
    end

    describe 'on failed when notice' do
      let(:exit_status) { double(:success? => false, :status => 127) }
      let(:notice_when_fail) { '@here' }

      it {
        subject.completed_task(task, exit_status)
        expect(@string_to_be_posted).to eq(<<-EOS)
:x: *[FAILED]* `$ rake sample` @here
>>> exit 127 from rake.example.com at #{time_now.to_s} RAILS_ENV=development
        EOS
      }
    end
  end
end
