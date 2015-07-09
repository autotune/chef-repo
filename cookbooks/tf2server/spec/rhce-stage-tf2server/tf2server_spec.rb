require 'spec_helper'

describe service('tf2-server'), :if => os[:family] == 'redhat' do
  it { should be_running.under('upstart') }
end

describe service('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
  it { should be_running }
end

