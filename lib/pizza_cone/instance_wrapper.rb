require "delegate"
module PizzaCone
  class InstanceWrapper < SimpleDelegator
    ACCESSIBLE_STATUSES = %w(online running_setup setup_failed)
    USERNAME = ENV.fetch("AWS_SSH_USERNAME")

    def initialize(stack, instance)
      @stack = stack
      super(instance)
    end

    def ssh_ip
      __getobj__.public_ip || __getobj__.elastic_ip
    end

    def accessible_via_ssh?
      ACCESSIBLE_STATUSES.include?(__getobj__.status)
    end

    def stack_name
      @stack.name
    end

    def stack
      @stack
    end

    def to_s
      hostnames = instance_hostname_block.call(self)
      <<-STR
      Host #{hostnames}
        Hostname #{ssh_ip}
        User #{USERNAME}

      STR
    end

    private

    def instance_hostname_block
      PizzaCone.configuration.instance_hostname_block || default_hostname_block
    end

    def default_hostname_block
      @default_hostname_block ||= Proc.new do |instance|
        "#{instance.hostname} #{stack.name}-#{instance.hostname}"
      end
    end

    attr_reader :stack
  end
end
