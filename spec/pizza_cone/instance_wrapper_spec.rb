describe PizzaCone::InstanceWrapper do
  let(:hostname) { "doubleeye" }
  let(:public_ip) { nil }
  let(:elastic_ip) { nil }
  let(:private_ip) { nil }
  let(:instance) do
    double(
      :instance,
      hostname: hostname,
      public_ip: public_ip,
      elastic_ip: elastic_ip,
      private_ip: private_ip
    )
  end
  let(:stack) { double(:stack, name: "test-stack") }

  describe "#publicly_accessible?" do
    subject { described_class.new(stack, instance).publicly_accessible? }

    context "if the instance has a public IP" do
      let(:public_ip) { "1.2.3.4" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "if the instance has an elastic IP" do
      let(:elastic_ip) { "1.2.3.4" }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "if the instance has a private IP only" do
      let(:private_ip) { "10.255.1.1" }
      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "#only_privately_accessible?" do
    let(:public_ip) { nil }
    let(:elastic_ip) { nil }
    let(:private_ip) { nil }

    subject { described_class.new(stack, instance).only_privately_accessible? }

    context "if the instance has a public IP" do
      let(:public_ip) { "1.2.3.4" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "if the instance has an elastic IP" do
      let(:elastic_ip) { "1.2.3.4" }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "if the instance has a private IP only" do
      let(:private_ip) { "10.100.1.2" }
      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "if the instance does not have a private IP" do
      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end

  shared_examples_for "sets common SSH options" do
    it "sets the Host option" do
      expect(subject).to include("Host doubleeye")
    end
    it "sets the Hostname option" do
      expect(subject).to include("Hostname 1.2.3.4")
    end

    it "sets the User option" do
      expect(subject).to include("User ")
    end

    it "does not set the ProxyCommand option" do
      expect(subject).to_not include("ProxyCommand ")
    end
  end

  describe "#to_s" do
    subject { described_class.new(stack, instance).to_s }

    context "when an instance has a public IP" do
      let(:public_ip) { "1.2.3.4" }
      let(:private_ip) { "10.100.1.2" }

      include_examples "sets common SSH options"
    end

    context "when an instance has an elastic IP" do
      let(:public_ip) { "1.2.3.4" }
      let(:private_ip) { "10.100.1.2" }

      include_examples "sets common SSH options"
    end

    context "when an instance has private IP only" do
      let(:private_ip) { "1.2.3.4" }

      context "if the stack name matches a proxy map regexp" do
        let(:stack) { double(:stack, name: "test-stack-with-test-id") }

        it "includes the ProxyCommand option" do
          expect(subject).to include("ProxyCommand ssh -q test-broker nc -q0 1.2.3.4 22")
        end
      end

      include_examples "sets common SSH options"
    end
  end
end
