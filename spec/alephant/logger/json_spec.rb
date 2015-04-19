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
    allow(log_file).to receive :sync= 
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

  shared_context "nested log hash" do
    let(:log_hash) do
      { "nest" => nest }
    end

    let(:nest) { { "bird" => "eggs" } }
  end

  shared_examples "nests flattened to strings" do
    include_context "nested log hash"

    specify do
      expect(log_file).to receive(:write) do |json_dump|
        expect(JSON.parse(json_dump)["nest"]).to eq nest.to_s
      end

      subject.send(level, log_hash)
    end
  end

  shared_examples "nesting allowed" do
    include_context "nested log hash"

    specify do
      expect(log_file).to receive(:write) do |json_dump|
        expect(JSON.parse json_dump).to eq log_hash
      end

      subject.send(level, log_hash)
    end
  end

  %w[debug info warn error].each do |level|
    describe "##{level}" do
      let(:level) { level }

      it_behaves_like "JSON logging"

      it_behaves_like "nests flattened to strings"

      context "with nesting allowed" do
        subject do
          described_class.new(log_path, true)
        end

        it_behaves_like "nesting allowed"
      end
    end
  end
end

