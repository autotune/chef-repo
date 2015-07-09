require 'spec_helper'

describe service('tf2-server'), :if => os[:family] == 'redhat' do
  it { should be_running.under('upstart') }
end

