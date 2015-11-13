require "instance_wrapper"

class OpsworksWrapper
  REGION = ENV.fetch("AWS_REGION")
  def initialize
    @opsworks = Aws::OpsWorks::Client.new(region: 'us-east-1')
  end

  def stacks
    @stacks ||= opsworks.describe_stacks.stacks
  end

  def instances
    @instances ||= get_running_instances
  end

  private

  attr_reader :opsworks

  def get_running_instances
    stacks.map do |stack|
      instances = opsworks.describe_instances(stack_id: stack.stack_id).instances
      instances.map {|i| InstanceWrapper.new(i) }.select {|i| i.accessible_via_ssh? }
    end.flatten!
  end
end
