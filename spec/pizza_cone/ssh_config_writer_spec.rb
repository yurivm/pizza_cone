require "fileutils"

describe PizzaCone::SSHConfigWriter do
  use_vcr_cassette

  def updated_config_section(config_str)
    /#{PizzaCone::SSHConfigWriter::CONFIG_COMMENT_MARKER}(.*?)#{PizzaCone::SSHConfigWriter::CONFIG_COMMENT_MARKER}/m.match(config_str)
  end

  def host_section(config_str)
    /Host\s(?<host>.*?)\s+Hostname\s(?<ip>[\d\.]+)\s+User\s(?<user>\w+)/.match(config_str)
  end

  def read_ssh_config
    IO.read(ssh_file_path)
  end

  describe "#write" do
    let(:fixtures_path) { File.expand_path("../../../fixtures/ssh_config/", __FILE__) }
    let(:backup_file_path) { File.join(fixtures_path, "config.bak") }
    let(:ssh_file_path) { File.join(fixtures_path, "config") }
    let(:src_file_path) { File.join(fixtures_path, "config.src") }
    let(:instances) { PizzaCone::OpsworksWrapper.new.instances }
    subject { described_class.new(instances).write }

    before do
      FileUtils.rm(backup_file_path, force: true)
      FileUtils.cp(src_file_path, ssh_file_path)
    end

    subject { described_class.new(instances).write }

    context "backups" do
      it "backs up the original file" do
        subject

        expect(File.exist?(backup_file_path)).to be(true)
      end

      it "does not alter the backup file" do
        subject
        expect(IO.read(backup_file_path)).to eq(IO.read(src_file_path))
      end
    end

    context "if the ssh config file did not exist" do
      let(:moved_config_file_path) { File.join(fixtures_path, "config.ghost") }

      before do
        FileUtils.mv(ssh_file_path, moved_config_file_path)
      end

      after do
        FileUtils.mv(moved_config_file_path, ssh_file_path)
      end

      it "creates the config file" do
        subject

        expect(File.exist?(ssh_file_path)).to be(true)
      end
    end

    context "updated ssh file" do
      it "prepends the host settings to the original config" do
        subject

        match = updated_config_section(read_ssh_config)
        expect(match[1]).to_not be_empty
      end

      it "puts a comment marker in the file" do
        subject

        expect(IO.read(ssh_file_path)).to include(PizzaCone::SSHConfigWriter::CONFIG_COMMENT_MARKER)
      end

      it "puts a host section and a username for a host" do
        subject

        settings = updated_config_section(read_ssh_config)
        host = host_section(settings[1])
        expect(host["host"]).not_to be_nil
        expect(host["ip"]).not_to be_nil
        expect(host["user"]).not_to be_nil
      end

      it "uses a custom block to write the host patterns string" do
        subject

        settings = updated_config_section(read_ssh_config)
        host = host_section(settings[1])
        expect(host["host"]).to include("and_bla")
      end
    end
  end
end
