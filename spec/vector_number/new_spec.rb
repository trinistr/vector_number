# frozen_string_literal: true

RSpec.describe VectorNumber, ".new", :aggregate_failures do
  subject(:new_number) { described_class.new(*arguments, &block) }

  let(:arguments) { [value] }
  let(:value) { nil }
  let(:block) { nil }

  let(:my_basic_class) { Class.new(BasicObject) { define_method(:hash, -> { 1 }) } }

  context "when initializing with nil" do
    it "returns zero" do
      expect(new_number).to be_zero
    end
  end

  context "when initializing with a vector number" do
    let(:value) { num("you", "are", "cute") }

    it "copies values from it" do
      expect(new_number).to be_a described_class
      expect(new_number).to be_frozen
      expect(new_number.to_a).to contain_exactly ["you", 1], ["are", 1], ["cute", 1]
    end
  end

  context "when initializing with an array" do
    let(:value) { [1, 0.25r, 2.5ri, "a", "a", :a, 0, -0.5, Complex(1, 2)] }

    it "adds everything together to form a vector" do
      expect(new_number).not_to be_zero
      expect(new_number.size).to eq 4
      expect(new_number).to eql num(1.75, 4.5ri, "a", "a", :a)
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
        expect(new_number).to eql num(18.25r, 4.1i, "s", "s")
      end
    end

    context "when array contains a BasicObject" do
      let(:value) { ["a", 14, basic_object, []] }
      let(:basic_object) { my_basic_class.new }

      it "successfully adds it" do
        expect(new_number.size).to eq 4
        expect(new_number.to_a)
          .to eq [["a", 1], [described_class::R, 14], [basic_object, 1], [[], 1]]
      end
    end
  end

  context "when initializing with a hash" do
    # Note how this has the proper unit for 1 and also just `1`.
    let(:value) { { described_class::R => 5, 1 => -123, basic_object => 0xC001, Encoding::UTF_8 => 1.337 } }
    let(:basic_object) { my_basic_class.new }

    it "treats hash as a plain vector and copies keys and values from it direcly" do
      expect(new_number).to be_a described_class
      expect(new_number).to be_frozen
      expect(new_number.to_a).to contain_exactly(
        [described_class::R, 5], [1, -123], [basic_object, 49_153], [Encoding::UTF_8, 1.337]
      )
    end

    context "when it contains non-real values" do
      let(:value) { { described_class::R => -123i, basic_object => Object.new, Encoding::UTF_8 => num } }

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
      expect(new_number).to contain_exactly(
        [described_class::R, 1.5r], [described_class::I, 1], ["s", 2]
      )
    end

    context "when transformation returns real vector number" do
      let(:block) { ->(v) { num(v + 1) } }

      it "works exactly the same as with a normal real number" do
        expect(new_number).to contain_exactly(
          [described_class::R, 1.5r], [described_class::I, 1], ["s", 2]
        )
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

    context "when transformation returns BasicObject value" do
      let(:block) { ->(_) { BasicObject.new } }

      it "raises RangeError" do
        expect { new_number }.to raise_error RangeError
      end
    end
  end

  context "when initializing with unsupported type" do
    let(:value) { Object.new }

    it "raises ArgumentError" do
      expect { new_number }.to raise_error ArgumentError
    end
  end

  context "when keyword arguments are passed" do
    it "raises ArgumentError" do
      expect { described_class.new([1], mult: :dot) }.to raise_error ArgumentError
    end
  end
end
