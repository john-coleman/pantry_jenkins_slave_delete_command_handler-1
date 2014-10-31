require 'rest_client'
require 'json'
require 'chef'
require 'chef/knife'
require 'mechanize'
require 'open-uri'

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
        result = RestClient.get("http://#{message['server_fqdn']}:#{server_port}/computer/api/json")
        node = get_node(message, result)
        return true if node.nil?
        credentials = jenkins_username_and_password(message["server_fqdn"]) || jenkins_username_and_password(message["hostname"] + "." + message["domain"])

        if credentials
          api_token = get_api_token(message["server_fqdn"], message["server_port"], credentials[:username], credentials[:password])
          @logger.info "Deleting #{node} slave with authentication"
          RestClient.post("http://#{credentials[:username]}:#{api_token}@#{message['server_fqdn']}:#{server_port}/computer/#{node}.#{message["domain"]}/doDelete", {})
        else
          @logger.info "Deleting #{node} slave without authentication"
          RestClient.post("http://#{message['server_fqdn']}:#{server_port}/computer/#{node}.#{message["domain"]}/doDelete", {})
        end
      end

      def get_node(message, result)
        h = JSON.parse(result)
        computers = h["computer"].map {|c| c["displayName"]}
        return message["hostname"].upcase if computers.include?("#{message["hostname"].upcase}.#{message["domain"]}")
        return message["hostname"] if computers.include?("#{message["hostname"]}.#{message["domain"]}")
        @logger.info "Node name not found" and nil
      end

      def jenkins_username_and_password(name)
        node = Chef::Node.load(name)
        begin
          unless node["jenkins"]["cli"]["username"].empty?
            { username: node["jenkins"]["cli"]["username"], password: node["jenkins"]["cli"]["password"] }
          end
        rescue NoMethodError => e
          @logger.info "Cannot find username and password of Jenkins server: #{e}"
          nil
        end
      end

      def get_api_token(server_fqdn, server_port = 80, username, password)
        url = "http://#{server_fqdn}:#{server_port}/login"
        api_url = "http://#{server_fqdn}:#{server_port}/me/configure"
        agent = Mechanize.new
        agent.get(url)
        form = agent.page.forms.last
        form.j_username = username
        form.j_password = password
        form.submit
        agent.get(api_url)
        api_token = agent.page.search("#apiToken").first.attributes["value"].value
      end
    end
  end
end
