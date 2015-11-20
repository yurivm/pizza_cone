module Pizzacone
  class OpsworksWrapper
    def initialize
      @opsworks = Aws::OpsWorks::Client.new(region: "us-east-1")
    end

    def stacks
      @stacks ||= opsworks.describe_stacks.stacks
    end

    def instances
      @instances ||= fetch_running_instances
    end

    private

    attr_reader :opsworks

    def fetch_running_instances
      stacks.map do |stack|
        instances = opsworks.describe_instances(stack_id: stack.stack_id).instances
        instances.map { |instance| InstanceWrapper.new(stack, instance) }.select(&:accessible_via_ssh?)
      end.flatten!
    end
  end
end
