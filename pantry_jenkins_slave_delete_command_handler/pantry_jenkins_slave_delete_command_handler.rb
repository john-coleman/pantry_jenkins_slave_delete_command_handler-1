require 'jenkins_api_client'

module Wonga
  module Daemon
    class PantryJenkinsSlaveDeleteCommandHandler
      def initialize(publisher, logger)
        @publisher = publisher
        @logger = logger
      end

      def handle_message(message)
        server_port = message['server_port'] || '80'
        @client = JenkinsApi::Client.new(server_ip: message['server_ip'], server_port: server_port)
        @logger.info "Deleting #{message['node']} slave"
        @client.node.delete(message['name'])
        @logger.info "Deleted #{message['node']} slave"
        @publisher.publish(message)
      end
    end
  end
end
