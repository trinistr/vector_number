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
      expect(number.to_a).to contain_exactly [1, 5], ["a", 1]
      expect(number).to be_frozen
    end
  end

  describe "#size" do
    it "returns number of non-zero dimensions" do
      expect(num.size).to be 0
      expect(num(1, -1).size).to be 0
      expect(num(4i).size).to be 1
      expect(num("1", 2, 3, 4).size).to be 2
      expect(num(*("a".."z").to_a).size).to be 26
    end
  end

  describe "#+@" do
    subject(:result) { +number }

    let(:number) { described_class.new([1.2, Complex(3, 12), :f]) }

    it "returns the number itself" do
      expect(result).to be number
    end
  end

  include_examples "has an alias", :dup, :+@

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
