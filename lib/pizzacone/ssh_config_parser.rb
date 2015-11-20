module Pizzacone
  module SSHConfigParser
    def global_options
      @global_options ||= Net::SSH::Config.load(ssh_config_file_path, "*")
    end

    def options_for_host(host_name)
      host_options = Net::SSH::Config.load(ssh_config_file_path, host_name)
      host_option_keys = host_options.keys - global_options.keys
      return {} if host_option_keys.empty?
      host_options.select { |key, _| host_option_keys.include?(key) }
    end

    def ssh_config_file_path
      Pizzacone.configuration.ssh_config_file_path
    end

    module_function :global_options, :options_for_host, :ssh_config_file_path
  end
end
