require "fileutils"

module Pizzacone
  class SSHConfigWriter
    CONFIG_COMMENT_MARKER = "### added by pizzacone ###"

    def initialize(instances)
      @instances = instances
    end

    def write
      backup_original_file
      read_config_file
      update_pizzacone_settings
      write_config_file
    end

    private

    attr_reader :instances, :config

    def read_config_file
      @config = begin
        IO.read(original_file_name)
      rescue Errno::ENOENT
        ""
      end
    end

    def update_pizzacone_settings
      new_settings = instances_settings
      require "pry"; binding.pry
      pizzacone_section_found? ? config.gsub(shady_regexp, new_settings) : config.prepend(new_settings)
    end

    def instances_settings
      settings = "#{CONFIG_COMMENT_MARKER}\n"
      instances.each { |instance| settings << instance.to_s }
      settings << "#{CONFIG_COMMENT_MARKER}\n"
    end

    def write_config_file
      File.open(original_file_name, "w") { |file| file.write(config) }
    end

    def backup_original_file
      FileUtils.cp(original_file_name, backup_file_name) if File.exist?(original_file_name)
    end

    def original_file_name
      File.expand_path(Pizzacone.configuration.ssh_config_file_path)
    end

    def backup_file_name
      File.expand_path(Pizzacone.configuration.backup_ssh_config_file_path)
    end

    def pizzacone_section_found?
      shady_regexp =~ config
    end

    def shady_regexp
      @regexp ||= Regexp.new(/#{CONFIG_COMMENT_MARKER}.*?#{CONFIG_COMMENT_MARKER}/m)
    end
  end
end
