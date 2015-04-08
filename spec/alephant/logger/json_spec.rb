require "spec_helper"

require "alephant/logger/json"

describe Alephant::Logger::JSON do
  subject do
    described_class.new log_path
  end

  let(:log_path) { "/log/path.log" }
  let(:log_file) { instance_double File }

  before do
    allow(File).to receive(:open) { log_file }
  end

  shared_examples "JSON logging" do
    let(:log_hash) do
      { "foo" => "bar", "baz" => "quux" }
    end

    it "writes JSON dump of hash to log with corresponding level key" do
      expect(log_file).to receive(:write) do |json_dump|
        expect(JSON.parse json_dump).to eq log_hash.merge("level" => level)
      end

      subject.send(level, log_hash)
    end
  end

  describe "log levels" do
    %w[debug info warn error].each do |level|
      it_behaves_like "JSON logging" do
        let(:level) { level }
      end
    end
  end
end

