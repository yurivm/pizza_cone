require 'fileutils'

class SSHConfigWriter

  def initialize(instances)
    @instances = instances
  end

  def write
    write_instance_options
    backup_original_file
    concat_new_ssh_file
  end

  private

  attr_reader :instances

  def new_config_file_name
    File.expand_path(Lessh.configuration.new_ssh_config_file_path)
  end

  def original_file_name
    File.expand_path(Lessh.configuration.ssh_config_file_path)
  end

  def backup_file_name
    File.expand_path(Lessh.configuration.backup_ssh_config_file_path)
  end

  def write_instance_options
    File.open(new_config_file_name, "w+") do |new_config|
      new_config.write(lessh_comment_line)
      instances.each do |i|
        puts "writing : #{i.to_s}"
        new_config.write(i.to_s)
      end
      new_config.write(lessh_comment_line)
    end
  end

  def lessh_comment_line
    "## Added by Lessh ##"
  end

  def concat_new_ssh_file
    exec("cat #{original_file_name} >> #{new_config_file_name} && mv #{new_config_file_name} #{original_file_name}")
  end

  def backup_original_file
    FileUtils.cp(original_file_name, backup_file_name)
  end
end
