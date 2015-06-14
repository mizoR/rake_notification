require 'spec_helper'

describe RakeNotification do
  subject { app }

  let(:app) { Rake::Application.new }

  let(:notifier) { double('notifier') }

  before {
    class Rake::Application; prepend RakeNotification; end

    allow(app).to receive(:invoke_task).and_return(true)
  }

  it { expect(described_class.config_path).to be_a String }

  it { is_expected.to be_respond_to :run }

  describe "#reconstruct_command_line" do
    subject { app.reconstructed_command_line }

    it {
      app.init
      is_expected.to be_a String
    }
  end

  describe '#register_interceptor' do
    subject { notifier }

    shared_examples_for 'an intercepter' do
      it 'should be call on started task' do
        is_expected.to receive(:call).with(app)

        app.run
      end
    end

    describe 'Instance notifier' do
      before { app.register_interceptor notifier }

      it_behaves_like 'an intercepter'
    end

    describe 'Proc notifier' do
      before { app.register_interceptor {|task| notifier.call(task)} }

      it_behaves_like 'an intercepter'
    end
  end

  describe '#register_observer' do
    subject { notifier }

    shared_examples_for 'an observer' do
      it 'should be call on completed task' do
        is_expected.to receive(:call).with(app, nil)

        app.run
      end

      context 'raise error on invoking task' do
        let(:err) { StandardError.new('Rake Error') }

        before { app.stub(:invoke_task).and_raise(err) }

        it 'should receive completed task' do
          is_expected.to     receive(:call).with(app, err)
          begin
            $stderr.reopen('/dev/null', 'w')
            app.run
          rescue SystemExit => e
            expect(e).not_to be_success
          else
            raise "Rake::Application#run should raise SystemExit, but did not."
          ensure
            $stderr = STDERR
          end
        end
      end
    end

    describe 'Instance notifier' do
      before { app.register_observer notifier }

      it_behaves_like 'an observer'
    end

    describe 'Proc notifier' do
      before { app.register_observer {|task, err| notifier.call(task, err) } }

      it_behaves_like 'an observer'
    end
  end
end
