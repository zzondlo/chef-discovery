module Discovery
  class << self

    def provider_for_node(node = nil)
      raise "Must pass a node" unless node
      if node.has_key? :cloud and
          node.cloud.has_key? :provider
        node.cloud.provider 
      else
        nil
      end
    end

    def ipaddress(options = {})
      raise "Options must be a hash" unless
        options.respond_to? :has_key?
      raise "Options does not contain a node key" unless
        options.has_key? :node
      raise "Options does not contain a remote_node key" unless
        options.has_key? :remote_node
      raise "Options type is invalid" if
        options.has_key? :type and
        options[:type].is_a? Symbol and not
        [:local, :public].any? { |o| o == options[:type] }

      options[:type] ||=
        if provider_for_node(options[:remote_node]) == provider_for_node(options[:node])
          :local
        else
          :public
        end

      Chef::Log.debug "ipaddress[#{options[:type]}]: attempting to determine ip address for #{options[:node].name}"

      [ (options[:remote_node].cloud.send("#{options[:type]}_ipv4") rescue nil),
        options[:remote_node].ipaddress ].detect do |attribute|
        begin
          ip = attribute
        rescue StandardError => standard_error
          Chef::Log.debug "ipaddress: error #{standard_error}"
          nil
        rescue Exception => exception
          Chef::Log.debug "ipaddress: exception #{exception}"
          nil
        end
      end
    end

  end
end

