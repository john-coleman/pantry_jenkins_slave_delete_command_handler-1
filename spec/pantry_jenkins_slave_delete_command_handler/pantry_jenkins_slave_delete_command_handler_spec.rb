require 'spec_helper'
require_relative '../../pantry_jenkins_slave_delete_command_handler/pantry_jenkins_slave_delete_command_handler'
require 'rest_client'
require 'chef'
require 'chef/knife'
require 'pry'

describe Wonga::Daemon::PantryJenkinsSlaveDeleteCommandHandler do
  let(:json_string_upper_case) {"{\"busyExecutors\":0,\"computer\":[{\"actions\":[],\"displayName\":\"master\",\"executors\":[{},{},{},{}],\"icon\":\"computer.png\",\"idle\":true,\"jnlpAgent\":false,\"launchSupported\":true,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":{\"availablePhysicalMemory\":976572416,\"availableSwapSpace\":0,\"totalPhysicalMemory\":7812575232,\"totalSwapSpace\":0},\"hudson.node_monitors.ArchitectureMonitor\":\"Linux (amd64)\",\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":0},\"hudson.node_monitors.TemporarySpaceMonitor\":{\"path\":\"/tmp\",\"size\":65203343360},\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":\"04.7\",\"hudson.node_monitors.DiskSpaceMonitor\":{\"path\":\"/var/lib/jenkins\",\"size\":65203331072},\"hudson.node_monitors.ClockMonitor\":{\"diff\":0}},\"numExecutors\":4,\"offline\":false,\"offlineCause\":null,\"offlineCauseReason\":\"\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"AGENT-000000001.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"AGENT-000000002.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"AGENT-000000006.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"AGENT-000000008.example.com\",\"executors\":[{}],\"icon\":\"computer.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":\"Windows Server 2008 R2 (amd64)\",\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":535},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":\"-1.0\",\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":{\"diff\":-15535}},\"numExecutors\":1,\"offline\":false,\"offlineCause\":null,\"offlineCauseReason\":\"\",\"oneOffExecutors\":[],\"temporarilyOffline\":false}],\"displayName\":\"nodes\",\"totalExecutors\":5}"}
  let(:json_string_down_case) {"{\"busyExecutors\":0,\"computer\":[{\"actions\":[],\"displayName\":\"master\",\"executors\":[{},{},{},{}],\"icon\":\"computer.png\",\"idle\":true,\"jnlpAgent\":false,\"launchSupported\":true,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":{\"availablePhysicalMemory\":976572416,\"availableSwapSpace\":0,\"totalPhysicalMemory\":7812575232,\"totalSwapSpace\":0},\"hudson.node_monitors.ArchitectureMonitor\":\"Linux (amd64)\",\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":0},\"hudson.node_monitors.TemporarySpaceMonitor\":{\"path\":\"/tmp\",\"size\":65203343360},\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":\"04.7\",\"hudson.node_monitors.DiskSpaceMonitor\":{\"path\":\"/var/lib/jenkins\",\"size\":65203331072},\"hudson.node_monitors.ClockMonitor\":{\"diff\":0}},\"numExecutors\":4,\"offline\":false,\"offlineCause\":null,\"offlineCauseReason\":\"\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"agent-000000001.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"agent-000000002.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"agent-000000006.example.com\",\"executors\":[{}],\"icon\":\"computer-x.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":null,\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":5000},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":null,\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":null},\"numExecutors\":1,\"offline\":true,\"offlineCause\":{},\"offlineCauseReason\":\"<span class=error style='display:inline-block'>Time out for last 5 try</span>\",\"oneOffExecutors\":[],\"temporarilyOffline\":false},{\"actions\":[],\"displayName\":\"agent-000000008.example.com\",\"executors\":[{}],\"icon\":\"computer.png\",\"idle\":true,\"jnlpAgent\":true,\"launchSupported\":false,\"loadStatistics\":{},\"manualLaunchAllowed\":true,\"monitorData\":{\"hudson.node_monitors.SwapSpaceMonitor\":null,\"hudson.node_monitors.ArchitectureMonitor\":\"Windows Server 2008 R2 (amd64)\",\"hudson.node_monitors.ResponseTimeMonitor\":{\"average\":535},\"hudson.node_monitors.TemporarySpaceMonitor\":null,\"hudson.plugins.network_monitor.NameResolutionMonitor\":null,\"hudson.plugins.systemloadaverage_monitor.SystemLoadAverageMonitor\":\"-1.0\",\"hudson.node_monitors.DiskSpaceMonitor\":null,\"hudson.node_monitors.ClockMonitor\":{\"diff\":-15535}},\"numExecutors\":1,\"offline\":false,\"offlineCause\":null,\"offlineCauseReason\":\"\",\"oneOffExecutors\":[],\"temporarilyOffline\":false}],\"displayName\":\"nodes\",\"totalExecutors\":5}"}
  let(:message) { {"hostname" => "jenkins-linux-agent", "domain" => "vagrant", "server_ip" => "localhost.lvh.me", "server_port" => "8080"} }
  let(:publisher) { instance_double('Publisher').as_null_object }
  let(:node_params) { { "username" => "ProvisionerUsername", "password" => "secret", "jvm_options" => "-Xmx50m -Xms5m" } }
  let(:node_empty_params) { { "username" => '', "password" => '' } }
  let(:node_nil_params) { { "username" => nil, "password" => nil } }
  subject { described_class.new(publisher, double.as_null_object) }
  it_behaves_like 'handler'
  
  describe "#send_delete" do
    it "sends the delete message" do
      VCR.use_cassette('synopsis') do
        RestClient.should_receive(:get).and_return(json_string_upper_case)
        subject.stub(:get_node).and_return("jenkins-linux-agent")
        subject.should_receive(:jenkins_username_and_password).with("jenkins-linux-agent").and_return(
          { username: "ProvisionerUsername", password: "secret" }
        )
        expect{subject.send_delete(message)}.to raise_error(RestClient::Found) # it gets a 302 error which is ok because it redirects after deletion
      end
    end
  end
  
  describe "#handle_message" do  
    it "publishes to the topic" do
      RestClient.stub(:get).and_return(json_string_upper_case)
      subject.stub(:get_node).and_return("jenkins-linux-agent")
      RestClient.stub(:post)
      publisher.should_receive(:publish)
      VCR.use_cassette('synopsis', record: :all) do # bypass VCR and use chef-zero server
        node = Chef::Node.new
        node.name("jenkins-linux-agent")
        node.default[:jenkins][:cli] = node_params
        node.save
        subject.stub(:get_api_token)
        
        subject.handle_message(message)
      end
    end
    
    it "can publish to the topic without authentication" do
      RestClient.stub(:get).and_return(json_string_upper_case)
      subject.stub(:get_node).and_return("jenkins-linux-agent")
      RestClient.stub(:post)
      publisher.should_receive(:publish)
      VCR.use_cassette('synopsis', record: :all) do # bypass VCR and use chef-zero server
        node = Chef::Node.new
        node.name("jenkins-linux-agent")
        node.save
        subject.stub(:get_api_token)
        
        subject.handle_message(message)
      end
    end
    
    it "calls send_delete" do
      subject.should_receive(:send_delete)
      subject.handle_message(message)
    end
  end
  
  describe "#get_node" do
    it "finds an upper case node" do
      subject.get_node({"hostname" => "agent-000000001", "domain" => "example.com"}, json_string_upper_case).should eq "AGENT-000000001"
    end
    
    it "finds a down case node" do
      subject.get_node({"hostname" => "agent-000000001", "domain" => "example.com"}, json_string_down_case).should eq "agent-000000001"
    end
  end
  
  describe "#jenkins_username_and_password" do
    it "returns username and password of a jenkins server" do
      VCR.use_cassette('synopsis', record: :all) do # bypass VCR and use chef-zero server
        node = Chef::Node.new
        node.name("host.example.com")
        node.default['os'] = "Linux"
        node.default[:jenkins][:cli] = node_params
        node.save
        subject.jenkins_username_and_password("host.example.com").should eq({ username: "ProvisionerUsername", password: "secret" })
      end
    end
    
    it "handles nodes with empty username and password" do
      VCR.use_cassette('synopsis', :record => :all) do
        node = Chef::Node.new
        node.name("host.example.com")
        node.default['os'] = "Linux"
        node.default[:jenkins][:cli] = node_empty_params
        node.save
        subject.jenkins_username_and_password("host.example.com").should be_nil
      end
    end

    it "handles nodes with nil username and password" do
      VCR.use_cassette('synopsis', :record => :all) do
        node = Chef::Node.new
        node.name("host.example.com")
        node.default['os'] = "Linux"
        node.default[:jenkins][:cli] = node_nil_params
        node.save
        subject.jenkins_username_and_password("host.example.com").should be_nil
      end
    end

    it "handles nodes with no username and password defined" do
      VCR.use_cassette('synopsis', :record => :all) do
        node = Chef::Node.new
        node.name("host.example.com")
        node.save
        subject.jenkins_username_and_password("host.example.com").should be_nil
      end
    end
  end
  
  describe "#get_api_token" do
    it "gets the token by connecting to the server and by scraping the value of the API token" do
      VCR.use_cassette('synopsis') do
        username = "ProvisionerUsername"
        password = "secret"
        server_ip = "localhost.lvh.me"
        server_port = 8080
        subject.get_api_token(server_ip, server_port, username, password).should eq "bfa4fe165a71ba7c16cd0865e88a6b30"
      end
    end
  end
end
