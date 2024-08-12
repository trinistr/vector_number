# frozen_string_literal: true

RSpec.describe VectorNumber, :aggregate_failures do
  it "has a proper version number" do
    expect(described_class::VERSION).not_to be_nil
    expect { Gem::Version.new(described_class::VERSION) }.not_to raise_error
  end

  describe ".[]" do
    subject(:number) { described_class[1, 4, "a"] }

    it "creates a new VectorNumber" do
      expect(number).to be_a described_class
      expect(number.to_a).to contain_exactly [0.i, 5], ["a", 1]
      expect(number).to be_frozen
    end

    context "when options are passed" do
      subject(:number) { described_class["1.2", Complex(3, 12), :f, **options] }

      let(:options) { { mult: :asterisk, wrong: :option } }

      it "sets known options" do
        expect(number.options).to eq(options.keep_if { |k, _v| described_class::KNOWN_OPTIONS.include?(k) })
      end
    end
  end

  describe ".new" do
    subject(:number) { described_class.new([1.2, Complex(3, 12), :f]) }

    it "creates a new VectorNumber with default options" do
      expect(number).to be_a described_class
      expect(number.to_a).to contain_exactly [0.i, 4.2], [1.i, 12], [:f, 1]
      expect(number).to be_frozen
      expect(number.options).to eq described_class::DEFAULT_OPTIONS
    end

    context "with explicit options" do
      subject(:number) { described_class.new(["1.2", Complex(3, 12), :f], options) }

      let(:options) { { mult: :asterisk, wrong: :option } }

      it "sets known options" do
        expect(number.options).to eq(options.keep_if { |k, _v| described_class::KNOWN_OPTIONS.include?(k) })
      end
    end
  end
end
