require "delegate"
module Pizzacone
  class InstanceWrapper < SimpleDelegator
    ACCESSIBLE_STATUSES = ["online", "running_setup", "setup_failed"]

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

    def to_s
      <<-STR
      Host #{hostname} #{stack.name}-#{hostname}
        Hostname #{ssh_ip}
        User #{ENV.fetch("AWS_SSH_USERNAME")}

      STR
    end

    private

    attr_reader :stack
  end
end
