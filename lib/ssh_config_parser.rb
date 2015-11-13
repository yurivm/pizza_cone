module SSHConfigParser
  SSH_CONFIG_FILE_PATH = "~/.ssh/config"

  def global_options
    @global_options ||= Net::SSH::Config.load(SSH_CONFIG_FILE_PATH, "*")
  end

  def options_for_host(host_name)
    host_options = Net::SSH::Config.load(SSH_CONFIG_FILE_PATH, host_name)
    host_option_keys = host_options.keys - global_options.keys
    return {} if host_option_keys.empty?
    host_options.select{|key, _| host_option_keys.include?(key) }
  end

  module_function :global_options, :options_for_host
end
