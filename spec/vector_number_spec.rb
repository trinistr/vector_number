# frozen_string_literal: true

RSpec.describe VectorNumber, :aggregate_failures do
  it "has a proper version number" do
    expect(described_class::VERSION).not_to be nil
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
        expect(number.options).to eq({ mult: :asterisk })
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
      let(:options) { { mult: :asterisk, wrong: :option } }

      context "when values are an Array" do
        subject(:number) { described_class.new(["1.2", Complex(3, 12), :f], options) }

        it "sets known options" do
          expect(number.options).to eq({ mult: :asterisk })
        end
      end

      context "when values are a VectorNumber" do
        subject(:number) { described_class.new(num("1.2", Complex(3, 12), :f), options) }

        it "sets known options" do
          expect(number.options).to eq({ mult: :asterisk })
        end
      end
    end
  end

  describe "#dup" do
    subject(:dupe) { number.dup }

    let(:number) { described_class.new([1.2, Complex(3, 12), :f]) }

    it "returns number itself" do
      expect(dupe.object_id).to eq number.object_id
    end
  end

  describe "#clone" do
    subject(:clone) { number.clone(**args) }

    let(:number) { described_class.new([1.2, Complex(3, 12), :f]) }

    context "when no argument is passed" do
      let(:args) { {} }

      it "returns number itself" do
        expect(clone.object_id).to eq number.object_id
      end
    end

    context "when true is passed as freeze argument" do
      let(:args) { { freeze: true } }

      it "returns number itself" do
        expect(clone.object_id).to eq number.object_id
      end
    end

    context "when nil is passed as freeze argument" do
      let(:args) { { freeze: nil } }

      it "returns number itself" do
        expect(clone.object_id).to eq number.object_id
      end
    end

    context "when false is passed as freeze argument" do
      let(:args) { { freeze: false } }

      it "raises ArgumentError the same as Numeric" do
        expect { clone }.to raise_error ArgumentError, "can't unfreeze VectorNumber"
      end
    end

    context "when something else is passed as freeze argument" do
      let(:args) { { freeze: "true" } }

      it "raises ArgumentError the same as Numeric" do
        expect { clone }.to raise_error ArgumentError, "unexpected value for freeze: String"
      end
    end
  end
end
