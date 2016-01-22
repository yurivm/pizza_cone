describe PizzaCone::IAMWrapper do
  use_vcr_cassette

  describe ".opsworks_ssh_username" do
    let(:user) do
      iam = Aws::IAM::Client.new(region: "us-east-1")
      iam.get_user.user
    end

    subject { described_class.opsworks_ssh_username }

    it "returns your IAM username with all the dots removed" do
      expect(subject).to eq(user.user_name.delete("."))
    end
  end
end
