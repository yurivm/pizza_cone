require "spec_helper"

describe PizzaCone::SSHConfigParser do
  describe ".global_options" do
    subject { described_class.global_options }

    it "returns correct global options" do
      expect(subject).to eq(
        "host" => "*",
        "visualhostkey" => true,
        "compression" => true,
        "compressionlevel" => 9,
        "serveraliveinterval" => 30,
        "serveralivecountmax" => 9999
      )
    end
  end

  describe ".options_for_host" do
    let(:host_name) { nil }
    subject { described_class.options_for_host(host_name) }

    context "when a host is present in the ssh config file" do
      let(:host_name) { "nix" }
      it "returns host specific options only" do
        expect(subject).to eq(
          "hostname" => "1.2.3.4",
          "user" => "yurivm"
        )
      end
    end

    context "when a host is not present in the ssh config file" do
      let(:host_name) { "limoncello" }
      it "returns an empty hash" do
        expect(subject).to eq({})
      end
    end

    context "when a host is present in the ssh config file more than once" do
      let(:host_name) { "salami" }
      it "returns the first match" do
        expect(subject).to eq(
          "hostname" => "54.155.206.162",
          "user" => "awesome1"
        )
      end
    end
  end
end
