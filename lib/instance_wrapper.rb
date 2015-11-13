require "delegate"

class InstanceWrapper < SimpleDelegator
  ACCESSIBLE_STATUSES = ["online", "running_setup", "setup_failed"]

  def ssh_ip
    __getobj__.public_ip || __getobj__.elastic_ip
  end

  def accessible_via_ssh?
    ACCESSIBLE_STATUSES.include?(__getobj__.status)
  end
end
