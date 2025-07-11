# frozen_string_literal: true

RSpec.describe VectorNumber, ".new", :aggregate_failures do
  subject(:new_number) { described_class.new(*arguments, &block) }

  let(:arguments) { [value] }
  let(:value) { nil }
  let(:options) { nil }
  let(:block) { nil }

  context "when initializing with nil" do
    it "returns zero" do
      expect(new_number).to be_zero
    end
  end

  context "when initializing with a vector number" do
    let(:value) { num("you", "are", "cute") }

    it "copies values and options from it" do
      expect(new_number).to be_a described_class
      expect(new_number).to be_frozen
      expect(new_number.to_a).to contain_exactly ["you", 1], ["are", 1], ["cute", 1]
      expect(new_number.options).to be value.options
    end
  end

  context "when initializing with an array" do
    let(:value) { [1, 0.25r, 2.5ri, "a", "a", :a, 0, -0.5, Complex(1, 2)] }

    it "creates a new VectorNumber with default options" do
      expect(new_number).to be_a described_class
      expect(new_number).to be_frozen
      expect(new_number.to_a).to contain_exactly [1, 1.75r], [2, 4.5r], [:a, 1], ["a", 2]
      expect(new_number.options).to eq described_class::DEFAULT_OPTIONS
    end

    it "adds everything together to form a vector" do
      expect(new_number).not_to be_zero
      expect(new_number.size).to eq 4
      expect(new_number).to eql num(1.75r, 4.5ri, "a", "a", :a)
    end

    context "when array is empty" do
      let(:value) { [] }

      it "returns zero" do
        expect(new_number).to be_zero
      end
    end

    context "when some coefficients are zero" do
      let(:value) { [0.i, Class] }

      it "compacts zeroes away" do
        expect(new_number.size).to eq 1
        expect(new_number).to contain_exactly [Class, 1]
      end
    end

    context "when array contains a vector number" do
      let(:value) { [0.25r, num(15r, Complex(3, 4.1), "s"), "s"] }

      it "adds values from vector to the rest" do
        expect(new_number.size).to eq 3
        expect(new_number).to eql num(18.25, 4.1i, "s", "s")
      end
    end

    context "when array contains vector numbers with options" do
      let(:value) { [0.25r, num(15r, Complex(3, 4.1), "s", mult: :cross), num("s", mult: "blank")] }

      it "copies options from the first vector encountered" do
        expect(new_number.size).to eq 3
        expect(new_number).to eql num(18.25, 4.1i, "s", "s")
        expect(new_number.options).to eq({ mult: :cross })
      end
    end
  end

  context "when initializing with a hash" do
    let(:value) { { 1 => -123, "u r" => 0xC001, Encoding::UTF_8 => 1.337 } }

    it "treats hash as a plain vector and copies values from it" do
      expect(new_number).to be_a described_class
      expect(new_number).to be_frozen
      expect(new_number.to_a).to contain_exactly(
        [1, -123], ["u r", 49_153], [Encoding::UTF_8, 1.337]
      )
      expect(new_number.options).to eq described_class::DEFAULT_OPTIONS
    end

    context "when it contains non-real values" do
      let(:value) { { 1 => -123i, "u r" => Object.new, Encoding::UTF_8 => num } }

      it "raises RangeError" do
        expect { new_number }.to raise_error RangeError
      end
    end
  end

  context "when a transform block is given" do
    let(:value) { [0.5r, 0.i, "s"] }
    let(:block) { ->(v) { v + 1 } }

    it "applies transformation before compaction" do
      expect(new_number.size).to eq 3
      expect(new_number).to contain_exactly [1, 1.5r], [2, 1], ["s", 2]
    end

    context "when transformation returns real vector number" do
      let(:block) { ->(v) { num(v + 1) } }

      it "works exactly the same as with a normal real number" do
        expect(new_number).to contain_exactly [1, 1.5r], [2, 1], ["s", 2]
      end
    end

    context "when transformation returns non-real number" do
      let(:block) { ->(v) { Complex(1, v) } }

      it "raises RangeError" do
        expect { new_number }.to raise_error RangeError
      end
    end

    context "when transformation returns non-real vector number" do
      let(:block) { ->(v) { num(v.to_s) } }

      it "raises RangeError" do
        expect { new_number }.to raise_error RangeError
      end
    end

    context "when transformation returns non-numeric value" do
      let(:block) { ->(v) { "a" * v } }

      it "raises RangeError" do
        expect { new_number }.to raise_error RangeError
      end
    end
  end

  context "when initializing with explicit options" do
    subject(:new_number) { described_class.new(value, options) }

    let(:options) { { mult: :asterisk, wrong: :option } }

    context "when values are an Array" do
      subject(:value) { ["1.2", Complex(3, 12), :f] }

      it "sets known options" do
        expect(new_number.options).to eq({ mult: :asterisk })
      end
    end

    context "when values are a VectorNumber" do
      subject(:value) { num("1.2", Complex(3, 12), :f) }

      it "sets known options" do
        expect(new_number.options).to eq({ mult: :asterisk })
      end
    end
  end

  context "when initializing with unsupported type" do
    let(:value) { Object.new }

    it "raises ArgumentError" do
      expect { new_number }.to raise_error ArgumentError
    end
  end
end
