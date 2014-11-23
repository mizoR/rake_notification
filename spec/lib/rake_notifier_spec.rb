require 'spec_helper'

describe RakeNotifier::Base do
  subject { anonymous_class.new }

  let(:anonymous_class) { Class.new(described_class) }

  its(:hostname)  { is_expected.to be_a String }
  its(:rails_env) { is_expected.to be_a String }
end
