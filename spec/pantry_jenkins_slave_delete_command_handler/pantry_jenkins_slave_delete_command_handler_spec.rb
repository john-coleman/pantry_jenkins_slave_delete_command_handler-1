require 'spec_helper'
require_relative '../../pantry_jenkins_slave_delete_command_handler/pantry_jenkins_slave_delete_command_handler'
require 'jenkins_api_client'

describe Wonga::Daemon::PantryJenkinsSlaveDeleteCommandHandler do
  let(:message) { {"node" => "jenkins-linux-agent.vagrant", "server_ip" => "127.0.0.1", "server_port" => "8080"} }
  let(:publisher) { instance_double('Publisher').as_null_object }
  subject { described_class.new(publisher, double.as_null_object) }
  it_behaves_like 'handler'
  
  describe "#handle_message" do
    before(:each) do
      @client = instance_double('JenkinsApi::Client')
      JenkinsApi::Client.stub(:new).and_return(@client)
    end
    
    it "sends the delete message" do
      node = instance_double('JenkinsApi::Client::Node')
      @client.should_receive(:node).and_return(node)
      node.should_receive(:delete)
      subject.handle_message(message)
    end
    
    it "publishes to the topic" do
      @client.stub_chain(:node, :delete)
      publisher.should_receive(:publish)
      subject.handle_message(message)
    end
  end
end
