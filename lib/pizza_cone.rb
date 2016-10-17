Bundler.require
Dotenv.load

module PizzaCone
  class Configuration
    DEFAULT_SSH_CONFIG_FILE_PATH = "~/.ssh/config"
    DEFAULT_BACKUP_SSH_CONFIG_FILE_PATH = "~/.ssh/config.bak"

    DEFAULT_INSTANCE_HOSTNAME_BLOCK = proc do |instance|
      instance_hostname = instance.hostname
      "#{instance_hostname} #{stack.name}-#{instance_hostname}"
    end

    DEFAULT_PROXY_COMMAND_BLOCK = proc { |_instance| "" }

    DEFAULT_AWS_REGION = "us-east-1"

    attr_writer :ssh_config_file_path, :backup_ssh_config_file_path, :proxy_map, :aws_region

    def ssh_config_file_path
      @ssh_config_file_path || DEFAULT_SSH_CONFIG_FILE_PATH
    end

    def backup_ssh_config_file_path
      @backup_ssh_config_file_path || DEFAULT_BACKUP_SSH_CONFIG_FILE_PATH
    end

    def proxy_map
      @proxy_map || {}
    end

    def aws_region
      @aws_region || DEFAULT_AWS_REGION
    end

    def define_instance_hostname_block(&block)
      @instance_hostname_block = block
    end

    def define_proxy_command_block(&block)
      @proxy_command_block = block
    end

    def instance_hostname_block
      @instance_hostname_block || DEFAULT_INSTANCE_HOSTNAME_BLOCK
    end

    def proxy_command_block
      @proxy_command_block || DEFAULT_PROXY_COMMAND_BLOCK
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.update_config
    instances = OpsworksWrapper.new.instances
    writer = SSHConfigWriter.new(instances)
    writer.write
  end
end

require_relative "./pizza_cone/opsworks_wrapper"
require_relative "./pizza_cone/ssh_config_writer"
