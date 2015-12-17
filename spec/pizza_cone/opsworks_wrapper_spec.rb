describe PizzaCone::OpsworksWrapper do
  use_vcr_cassette

  describe "#stacks" do
    subject { described_class.new.stacks }

    it "returns an array" do
      expect(subject).to be_a(Array)
    end

    it "returns an array of Aws::OpsWorks::Types::Stack" do
      subject.each do |stack|
        expect(stack).to be_a(Aws::OpsWorks::Types::Stack)
      end
    end

    it "returns stack ID for each stack" do
      subject.map do |stack|
        expect(stack.stack_id).to_not be_nil
      end
    end
  end

  describe "#instances" do
    subject { described_class.new.instances }
    let(:accessible_statuses) { %w(online running_setup setup_failed) }

    it "returns an array of instances" do
      expect(subject).to be_a(Array)
    end

    it "returns an array of InstanceWrappers" do
      subject.each do |host|
        expect(host).to be_a(PizzaCone::InstanceWrapper)
      end
    end

    it "returns hostname for each host" do
      subject.each do |host|
        expect(host.hostname).to_not be_nil
      end
    end

    it "returns SSH IP address for each host" do
      subject.each do |host|
        expect(host.ssh_ip).to_not be_nil
      end
    end

    it "returns instances that can be accessed via SSH" do
      subject.each do |host|
        expect(accessible_statuses).to include(host.status)
      end
    end
  end
end
