require "delegate"

module PizzaCone
  class InstanceWrapper < SimpleDelegator
    ACCESSIBLE_STATUSES = %w(online running_setup setup_failed)
    USERNAME = ENV.fetch("AWS_SSH_USERNAME")

    attr_reader :stack

    def initialize(stack, instance)
      @stack = stack
      super(instance)
    end

    def ssh_ip
      public_ip || elastic_ip || private_ip
    end

    def accessible_via_ssh?
      ACCESSIBLE_STATUSES.include?(status)
    end

    def publicly_accessible?
      public_ip? || elastic_ip?
    end

    def only_privately_accessible?
      !public_ip? && !elastic_ip? && private_ip?
    end

    def stack_name
      stack.name
    end

    def proxy_hostname
      @proxy_hostname ||= begin
        _, host = PizzaCone.configuration.proxy_map.find { |regexp, _| stack_name =~ regexp }
        host
      end
    end

    def to_s
      hostnames = instance_hostname_block.call(self)
      strings = [
        "Host #{hostnames}",
        "Hostname #{ssh_ip}",
        "User #{USERNAME}",
        proxy_command,
        "\n"
      ].compact

      strings.join("\n")
    end

    private

    def proxy_command
      proxy_command_block.call(self) if proxy_hostname && only_privately_accessible?
    end

    def public_ip?
      !public_ip.nil?
    end

    def elastic_ip?
      !elastic_ip.nil?
    end

    def private_ip?
      !private_ip.nil?
    end

    def instance_hostname_block
      PizzaCone.configuration.instance_hostname_block
    end

    def proxy_command_block
      PizzaCone.configuration.proxy_command_block
    end

    attr_reader :stack, :matching_proxy
  end
end
