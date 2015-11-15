Bundler.require
Dotenv.load

require "instance_wrapper"
require "opsworks_wrapper"
require "ssh_config_parser"
require "ssh_config_writer"

module Lessh
  class Configuration
    DEFAULT_SSH_CONFIG_FILE_PATH = "~/.ssh/config"
    DEFAULT_NEW_SSH_CONFIG_FILE_PATH = "~/.ssh/config.new"
    DEFAULT_BACKUP_SSH_CONFIG_FILE_PATH = "~/.ssh/config.bak"

    attr_writer :ssh_config_file_path, :new_ssh_config_file_path, :backup_ssh_config_file_path

    def ssh_config_file_path
      @ssh_config_file_path || DEFAULT_SSH_CONFIG_FILE_PATH
    end

    def new_ssh_config_file_path
      @new_ssh_config_file_path || DEFAULT_NEW_SSH_CONFIG_FILE_PATH
    end

    def backup_ssh_config_file_path
      @backup_ssh_config_file_path || DEFAULT_BACKUP_SSH_CONFIG_FILE_PATH
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
