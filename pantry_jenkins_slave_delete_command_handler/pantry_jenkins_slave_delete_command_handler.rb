require 'rest_client'
require 'json'

module Wonga
  module Daemon
    class PantryJenkinsSlaveDeleteCommandHandler
      def initialize(publisher, logger)
        @publisher = publisher
        @logger = logger
      end

      def handle_message(message)
        send_delete(message)
        @publisher.publish(message)
      end
      
      def send_delete(message)
        server_port = message['server_port'] || '80'
        result = RestClient.get("http://#{message['server_ip']}:#{server_port}/computer/api/json")
        node = get_node(message, result)
        return true if node.nil?
        @logger.info "Deleting #{node} slave"
        RestClient.post("http://#{message['server_ip']}:#{server_port}/computer/#{node}.#{message["domain"]}/doDelete", {})
      end
      
      def get_node(message, result)
        h = JSON.parse(result)
        computers = h["computer"].map {|c| c["displayName"]}
        return message["hostname"].upcase if computers.include?("#{message["hostname"].upcase}.#{message["domain"]}")
        return message["hostname"] if computers.include?("#{message["hostname"]}.#{message["domain"]}")
        @logger.info "Node name not found" and nil
      end
    end
  end
end
