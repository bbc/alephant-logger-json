require "date"
require "spec_helper"
require "alephant/logger/json_to_io"

describe Alephant::Logger::JSONtoIO do
  subject { described_class.new(logger_io) }

  let(:fn)        { -> { "foo" } }
  let(:logger_io) { spy }

  shared_examples "JSON logging" do
    let(:log_hash) do
      { "foo" => "bar", "baz" => "quux" }
    end

    it "writes JSON dump of hash to log with corresponding level key" do
      allow(Time).to receive(:now).and_return("foobar")

      expect(logger_io).to receive(:puts) do |json_dump|
        h = { "timestamp" => "foobar", "uuid" => "n/a", "level" => level }
        expect(JSON.parse json_dump).to eq h.merge log_hash
      end

      subject.public_send(level, log_hash)
    end

    it "automatically includes a timestamp" do
      expect(logger_io).to receive(:puts) do |json_dump|
        t = JSON.parse(json_dump)["timestamp"]
        expect{DateTime.parse(t)}.to_not raise_error
      end

      subject.public_send(level, log_hash)
    end

    it "outputs the timestamp first" do
      expect(logger_io).to receive(:puts) do |json_dump|
        h = JSON.parse(json_dump)
        expect(h.first[0].to_sym).to be :timestamp
      end

      subject.public_send(level, log_hash)
    end

    it "displays a default session value if a custom function is not provided" do
      expect(logger_io).to receive(:puts) do |json_dump|
        h = JSON.parse(json_dump)
        expect(h["uuid"]).to eq "n/a"
      end

      subject.public_send(level, log_hash)
    end

    it "displays a custom session value when provided a user defined function" do
      expect(logger_io).to receive(:puts) do |json_dump|
        h = JSON.parse(json_dump)
        expect(h["uuid"]).to eq "foo"
      end

      described_class.session = fn
      subject.send(level, binding, log_hash)
      described_class.session = -> { "n/a" }
    end

    it "provides a static method for checking if a session has been set" do
      described_class.session = fn
      expect(described_class.session?).to eq "instance-variable"

      described_class.remove_instance_variable :@session
      expect(described_class.session?).to eq nil
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
      expect(logger_io).to receive(:puts) do |json_dump|
        expect(JSON.parse(json_dump)["nest"]).to eq nest.to_s
      end

      subject.public_send(level, log_hash)
    end
  end

  shared_examples "nesting allowed" do
    include_context "nested log hash"

    specify do
      expect(logger_io).to receive(:puts) do |json_dump|
        expect(JSON.parse json_dump).to eq log_hash
      end

      subject.public_send(level, log_hash)
    end
  end

  shared_examples "gracefully fail with string arg" do
    let(:log_message) { "Unable to connect to server" }

    specify { expect(logger_io).not_to receive(:puts) }
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
        subject { described_class.new(logger_io, nesting: true) }

        it_behaves_like "nesting allowed"
      end
    end
  end
end
