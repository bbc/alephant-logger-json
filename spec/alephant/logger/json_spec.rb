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

  shared_context "flat log hash" do
    let(:log_hash) do
      { "foo" => "bar", "baz" => "quux" }
    end
  end

  shared_examples "JSON logging" do
    include_context "flat log hash"

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

  shared_examples "gracefully fail with string arg" do
    let(:log_message) { "Unable to connect to server" }

    specify { expect(log_file).not_to receive(:write) }
    specify do
      expect { subject.debug log_message }.not_to raise_error
    end
  end

  shared_examples "logs calling methods" do
    include_context "flat log hash"

    specify do
      expect(log_file).to receive(:write) do |json|
        expect(JSON.parse(json)["method"]).to eq "Dummy#dum"
      end

      class Dummy
        def dum(subject, level, log_hash)
          subject.send(level, log_hash)
        end
      end

      Dummy.new.dum(subject, level, log_hash)
    end
  end

  %w(debug info warn error).each do |level|
    describe "##{level}" do
      let(:level) { level }

      it_behaves_like "JSON logging"

      it_behaves_like "nests flattened to strings"

      it_behaves_like "gracefully fail with string arg"

      context "with nesting allowed" do
        subject do
          described_class.new(log_path, :nesting => true)
        end

        it_behaves_like "nesting allowed"
      end

      context "when logging calling methods" do
        subject do
          described_class.new(log_path, :log_methods => true)
        end

        it_behaves_like "logs calling methods"
      end
    end
  end
end
