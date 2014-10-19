require 'spec_helper'

describe RakeNotification do
  using RakeNotification

  subject { app }

  let(:app) { Rake::Application.new }

  let(:notifier) { double('notifier') }

  before {
    allow(app).to receive(:invoke_task).and_return(true)
  }

  it { expect(described_class.config_path).to be_a String }

  it { should be_respond_to :run }

  describe "#reconstruct_command_line" do
    subject { app.reconstructed_command_line }

    it {
      app.init
      should be_a String
    }
  end

  describe '#register_interceptor' do
    subject { notifier }

    before { app.register_interceptor notifier }

    it '#started_task が実行されること' do
      should     receive(:started_task).with(app)
      should_not receive(:completed_task)

      app.run
    end
  end

  describe '#register_observer' do
    subject { notifier }

    before { app.register_observer notifier }

    it '#completed_task が実行されること' do
      should_not receive(:started_task)
      should     receive(:completed_task)

      app.run
    end

    context 'タスクの実行中に例外が発生' do
      before { app.stub(:invoke_task).and_raise(StandardError.new('Rake Error')) }

      it '#completed_task が実行されること' do
        should_not receive(:started_task)
        should     receive(:completed_task).with(app, kind_of(SystemExit))
        begin
          $stderr.reopen('/dev/null', 'w')
          app.run
        rescue SystemExit => e
          expect(e).not_to be_success
        rescue => e
          raise e
        else
          raise "Rake::Application#run should raise SystemExit, but did not."
        ensure
          $stderr = STDERR
        end
      end
    end
  end
end
