# frozen_string_literal: true

RSpec.describe VectorNumber, :aggregate_failures do
  it "has a proper version number" do
    expect(described_class::VERSION).not_to be nil
    expect { Gem::Version.new(described_class::VERSION) }.not_to raise_error
  end

  describe ".[]" do
    context "with a list of values" do
      subject(:number) { described_class[1, 4, "a"] }

      it "creates a new VectorNumber from the list, adding values together" do
        expect(number).to be_a described_class
        expect(number.to_a).to contain_exactly [described_class::R, 5], ["a", 1]
        expect(number).to be_frozen
      end

      it "raises ArgumentError if a block is passed" do
        expect { described_class[1, 2, 3] { 4 } }.to raise_error ArgumentError
      end
    end

    context "with a hash of values" do
      subject(:number) { described_class[described_class::R => 5, "a" => 3.3] }

      it "creates a new VectorNumber from the hash directly" do
        expect(number).to be_a described_class
        expect(number.to_a).to contain_exactly [described_class::R, 5], ["a", 3.3]
        expect(number).to be_frozen
      end

      it "raises ArgumentError if a block is passed" do
        expect { described_class["a" => 3.3, :b => 4] { 4 } }.to raise_error ArgumentError
      end
    end

    it "raises ArgumentError if both positional and keyword arguments are passed" do
      expect { described_class[1, 2, 3, "c" => 4] }.to raise_error ArgumentError
    end
  end

  describe ".numeric_unit?" do
    it "returns true for special numeric units" do
      expect(described_class.numeric_unit?(described_class::R)).to be true
      expect(described_class.numeric_unit?(described_class::I)).to be true
    end

    it "returns false for non-numeric special units" do
      expect(described_class.numeric_unit?(described_class::SpecialUnit.new("my unit"))).to be false
    end

    it "returns false for regular units" do
      expect(described_class.numeric_unit?(:a)).to be false
      expect(described_class.numeric_unit?(1)).to be false
    end
  end

  describe ".special_unit?" do
    it "returns true for special numeric units" do
      expect(described_class.special_unit?(described_class::R)).to be true
      expect(described_class.special_unit?(described_class::I)).to be true
    end

    it "returns true for non-numeric special units" do
      expect(described_class.special_unit?(described_class::SpecialUnit.new("my unit"))).to be true
    end

    it "returns false for regular units" do
      expect(described_class.special_unit?(:a)).to be false
      expect(described_class.special_unit?(1)).to be false
    end
  end

  describe ".unit?" do
    it "is an alias of .special_unit?" do
      expect(described_class.method(:unit?).unbind.original_name).to eq :special_unit?
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
      it "raises ArgumentError the same as Numeric" do
        expect { number.clone(freeze: "true") }
          .to raise_error ArgumentError, "unexpected value for freeze: String"
        expect { number.clone(freeze: BasicObject.new) }
          .to raise_error ArgumentError, "unexpected value for freeze: BasicObject"
      end
    end
  end
end
