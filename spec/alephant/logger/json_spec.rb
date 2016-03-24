require "date"
require "spec_helper"
require "alephant/logger/json"

describe Alephant::Logger::JSON do
  subject do
    described_class.new log_path
  end

  let(:fn)       { -> { "foo" } }
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
      allow(Time).to receive(:now).and_return("foobar")

      expect(log_file).to receive(:write) do |json_dump|
        h = { "timestamp" => "foobar", "uuid" => "n/a", "level" => level }
        expect(JSON.parse json_dump).to eq h.merge log_hash
      end

      subject.send(level, log_hash)
    end

    it "automatically includes a timestamp" do
      expect(log_file).to receive(:write) do |json_dump|
        t = JSON.parse(json_dump)["timestamp"]
        expect{DateTime.parse(t)}.to_not raise_error
      end

      subject.send(level, log_hash)
    end

    it "outputs the timestamp first" do
      expect(log_file).to receive(:write) do |json_dump|
        h = JSON.parse(json_dump)
        expect(h.first[0].to_sym).to be :timestamp
      end

      subject.send(level, log_hash)
    end

    it "displays a default session value if a custom function is not provided" do
      expect(log_file).to receive(:write) do |json_dump|
        h = JSON.parse(json_dump)
        expect(h["uuid"]).to eq "n/a"
      end

      subject.send(level, log_hash)
    end

    it "displays a custom session value when provided a user defined function" do
      expect(log_file).to receive(:write) do |json_dump|
        h = JSON.parse(json_dump)
        expect(h["uuid"]).to eq "foo"
      end

      ::Alephant::Logger::JSON.session fn
      subject.send(level, log_hash)
      ::Alephant::Logger::JSON.session -> { "n/a" }
    end

    it "provides a static method for checking if a session has been set" do
      ::Alephant::Logger::JSON.session fn
      expect(::Alephant::Logger::JSON.session?).to eq "class variable"

      ::Alephant::Logger::JSON.remove_class_variable :@@session
      expect(::Alephant::Logger::JSON.session?).to eq nil
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
    end
  end
end
