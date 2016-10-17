module PizzaCone
  class IAMWrapper
    DOT = "."

    class << self
      def opsworks_ssh_username
        new.opsworks_ssh_username
      end
    end

    def initialize
      @iam = Aws::IAM::Client.new(region: PizzaCone.configuration.aws_region)
    end

    def opsworks_ssh_username
      user.user_name.delete(DOT)
    end

    def user
      @user ||= @iam.get_user.user
    end
  end
end
