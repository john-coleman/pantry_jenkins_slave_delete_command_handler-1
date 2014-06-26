require 'spec_helper'
require_relative '../../pantry_jenkins_slave_delete_command_handler/pantry_jenkins_slave_delete_command_handler'
require 'rest_client'
require 'chef'
require 'chef/knife'
require 'pry'
require 'wonga/daemon/publisher'

describe Wonga::Daemon::PantryJenkinsSlaveDeleteCommandHandler do
  let(:json_string) { "{\"busyExecutors\":0,\"computer\":[{\"actions\":[],\"displayName\":\"master\",\"executors\":[{},{},{},{}],\"icon\":\"computer.png\",\"idle\":true,\"jnlpAgent\":false,\"launchSupported\":true,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":{\"availablePhysicalMemory\":976572416,\"availableSwapSpace\":0,\"totalPhysicalMemory\":7812575232,\"totalSwapSpace\":0},\"hudson.node_monitors.ArchitectureMonitor\":\"Linux (amd64)\",\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":0},\"hudson.node_monitors.TemporarySpaceMonitor\":{\"path\":\"/tmp\",\"size\":65203343360},\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":\"04.7\",\"hudson.node_monitors.DiskSpaceMonitor\":{\"path\":\"/var/lib/jenkins\",\"size\":65203331072},\"hudson.node_monitors.ClockMonitor\":{\"diff\":0}},\"numExecutors\":4,\"offline\":false,\"offlineCause\":null,\"offlineCauseReason\":\"\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"AGENT-000000001.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"AGENT-000000002.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"AGENT-000000006.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"AGENT-000000008.example.com\",\"executors\":[{}],\"icon\":\"computer.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":\"Windows Server 2008 R2 (amd64)\",\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":535},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":\"-1.0\",\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":{\"diff\":-15535}},\"numExecutors\":1,\"offline\":false,\"offlineCause\":null,\"offlineCauseReason\":\"\",\"oneOffExecutors\":[],\"temporarilyOffline\":false}],\"displayName\":\"nodes\",\"totalExecutors\":5}" }
  let(:server) { 'localhost.lvh.me' }
  let(:publisher) { instance_double(Wonga::Daemon::Publisher) }
  let(:node_params) { { 'username' => 'ProvisionerUsername', 'password' => 'secret', 'jvm_options' => '-Xmx50m -Xms5m' } }
  let(:node) do
    node = Chef::Node.new
    node.name(server)
    node.default[:jenkins][:cli] = node_params
    node
  end

  subject(:handler) { described_class.new(publisher, double.as_null_object) }

  it_behaves_like 'handler'

  describe '#handle_message' do
    let(:message) { { 'hostname' => 'jenkins-linux-agent', 'domain' => 'vagrant', 'server_ip' => server, 'server_port' => '8080' } }

    before :each do
      allow(RestClient).to receive(:get).and_return(json_string)
      allow(subject).to receive(:jenkins_username_and_password).with(server).and_return(
        username: 'ProvisionerUsername', password: 'secret'
      )
      allow(subject).to receive(:get_api_token)
    end

    it 'publishes to the topic' do
      allow(subject).to receive(:get_node).and_return('jenkins-linux-agent')
      allow(RestClient).to receive(:post)
      expect(publisher).to receive(:publish)
      node.save
      subject.handle_message(message)
    end

    it 'can publish to the topic without authentication' do
      allow(RestClient).to receive(:get).and_return(json_string)
      allow(subject).to receive(:get_node).and_return('jenkins-linux-agent')
      allow(RestClient).to receive(:post)
      expect(publisher).to receive(:publish)
      node.save
      allow(subject).to receive(:get_api_token)

      subject.handle_message(message)
    end
  end

  describe '#get_node' do
    subject { handler.get_node({ 'hostname' => 'agent-000000001', 'domain' => 'example.com' }, json_string) }

    context "when node is saved in uppercase" do
      it 'finds an upper case node' do
        expect(subject).to eq 'AGENT-000000001'
      end
    end

    context 'when node is saved in downcase' do
      let(:json_string) { "{\"busyExecutors\":0,\"computer\":[{\"actions\":[],\"displayName\":\"master\",\"executors\":[{},{},{},{}],\"icon\":\"computer.png\",\"idle\":true,\"jnlpAgent\":false,\"launchSupported\":true,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":{\"availablePhysicalMemory\":976572416,\"availableSwapSpace\":0,\"totalPhysicalMemory\":7812575232,\"totalSwapSpace\":0},\"hudson.node_monitors.ArchitectureMonitor\":\"Linux (amd64)\",\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":0},\"hudson.node_monitors.TemporarySpaceMonitor\":{\"path\":\"/tmp\",\"size\":65203343360},\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":\"04.7\",\"hudson.node_monitors.DiskSpaceMonitor\":{\"path\":\"/var/lib/jenkins\",\"size\":65203331072},\"hudson.node_monitors.ClockMonitor\":{\"diff\":0}},\"numExecutors\":4,\"offline\":false,\"offlineCause\":null,\"offlineCauseReason\":\"\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"agent-000000001.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"agent-000000002.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"agent-000000006.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"agent-000000008.example.com\",\"executors\":[{}],\"icon\":\"computer.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":\"Windows Server 2008 R2 (amd64)\",\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":535},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":\"-1.0\",\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":{\"diff\":-15535}},\"numExecutors\":1,\"offline\":false,\"offlineCause\":null,\"offlineCauseReason\":\"\",\"oneOffExecutors\":[],\"temporarilyOffline\":false}],\"displayName\":\"nodes\",\"totalExecutors\":5}" }

      it 'finds a down case node' do
        expect(subject).to eq 'agent-000000001'
      end
    end
  end

  describe '#jenkins_username_and_password' do
    before(:each) do
      node.save
    end

    subject { handler.jenkins_username_and_password(server) }

    it 'returns username and password of a jenkins server' do
      expect(subject).to eq(username: 'ProvisionerUsername', password: 'secret')
    end

    context 'when node has empty params' do
      let(:node_params) { { 'username' => '', 'password' => '' } }

      it { is_expected.to be nil }
    end

    context 'when node has nil params' do
      let(:node_params) { { 'username' => nil, 'password' => nil } }

      it { is_expected.to be nil }
    end

    context 'when node has no params' do
      let(:node) do
        node = Chef::Node.new
        node.name(server)
        node
      end

      it { is_expected.to be nil }
    end
  end

  describe '#get_api_token' do
    it 'gets the token by connecting to the server and by scraping the value of the API token' do
      VCR.use_cassette('synopsis') do
        username = 'ProvisionerUsername'
        password = 'secret'
        server_ip = 'localhost.lvh.me'
        server_port = 8080
        expect(subject.get_api_token(server_ip, server_port, username, password)).to eq 'bfa4fe165a71ba7c16cd0865e88a6b30'
      end
    end
  end
end
