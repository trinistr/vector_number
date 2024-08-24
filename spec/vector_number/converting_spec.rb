# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"

RSpec.describe VectorNumber::Converting do
  let(:zero_number) { num }
  let(:real_number) { num(999.13) }
  let(:complex_number) { num(Complex(0.1, -13.4)) }
  let(:composite_number) { num("y", :a, 5, Complex(3, 5), 1.3i) }

  describe "#real" do
    subject(:real_part) { number.real }

    shared_examples "returns real part" do |for_number:, value:|
      context "with #{for_number.to_s.tr("_", " ")}" do
        let(:number) { public_send(for_number) }

        it "returns real part of the number" do
          expect(real_part).to eq value
        end
      end
    end

    include_examples "returns real part", for_number: :zero_number, value: 0
    include_examples "returns real part", for_number: :real_number, value: 999.13
    include_examples "returns real part", for_number: :complex_number, value: 0.1
    include_examples "returns real part", for_number: :composite_number, value: 8
  end

  describe "#imaginary" do
    subject(:imaginary_part) { number.imaginary }

    shared_examples "returns imaginary part" do |for_number:, value:|
      context "with #{for_number.to_s.tr("_", " ")}" do
        let(:number) { public_send(for_number) }

        it "returns imaginary part of the number" do
          expect(imaginary_part).to eq value
        end
      end
    end

    include_examples "returns imaginary part", for_number: :zero_number, value: 0
    include_examples "returns imaginary part", for_number: :real_number, value: 0
    include_examples "returns imaginary part", for_number: :complex_number, value: -13.4
    include_examples "returns imaginary part", for_number: :composite_number, value: 6.3
  end

  describe "#imag" do
    it "is an alias of #imaginary" do
      expect(described_class.instance_method(:imag).original_name).to be :imaginary
    end
  end

  describe "#to_i" do
    subject(:conversion) { number.to_i }

    context "with zero" do
      let(:number) { zero_number }

      it "returns value truncated to integer" do
        expect(conversion).to be 0
      end
    end

    context "with real number" do
      let(:number) { real_number }

      it "returns value truncated to integer" do
        expect(conversion).to be 999
      end
    end

    context "with complex number" do
      let(:number) { complex_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end

    context "with composite number" do
      let(:number) { composite_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end
  end

  describe "#to_int" do
    it "is an alias of #to_i" do
      expect(described_class.instance_method(:to_int).original_name).to be :to_i
    end
  end

  describe "#to_f" do
    subject(:conversion) { number.to_f }

    context "with zero" do
      let(:number) { zero_number }

      it "returns value as a Float" do
        expect(conversion).to be 0.0
      end
    end

    context "with real number" do
      let(:number) { real_number }

      it "returns value as a Float" do
        expect(conversion).to be 999.13
      end
    end

    context "with complex number" do
      let(:number) { complex_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end

    context "with composite number" do
      let(:number) { composite_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end
  end

  describe "#to_r" do
    subject(:conversion) { number.to_r }

    context "with zero" do
      let(:number) { zero_number }

      it "returns value as a Rational" do
        expect(conversion).to eql 0r
      end
    end

    context "with real number" do
      let(:number) { real_number }

      it "returns value as a Rational" do
        expect(conversion).to eql 999.13.to_r
      end
    end

    context "with complex number" do
      let(:number) { complex_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end

    context "with composite number" do
      let(:number) { composite_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end
  end

  describe "#to_d" do
    subject(:conversion) { number.to_d }

    context "with zero" do
      let(:number) { zero_number }

      it "returns value as a BigDecimal" do
        expect(conversion).to eql BigDecimal("0")
      end
    end

    context "with real number" do
      let(:number) { real_number }

      it "returns value as a BigDecimal" do
        expect(conversion).to eql BigDecimal("999.13")
      end
    end

    context "with complex number" do
      let(:number) { complex_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end

    context "with composite number" do
      let(:number) { composite_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end
  end

  describe "#to_c" do
    subject(:conversion) { number.to_c }

    context "with zero" do
      let(:number) { zero_number }

      it "returns value as a Complex" do
        expect(conversion).to eql Complex(0, 0)
      end
    end

    context "with real number" do
      let(:number) { real_number }

      it "returns value as a Complex" do
        expect(conversion).to eql Complex(999.13, 0)
      end
    end

    context "with complex number" do
      let(:number) { complex_number }

      it "returns value as a Complex" do
        expect(conversion).to eql Complex(0.1, -13.4)
      end
    end

    context "with composite number" do
      let(:number) { composite_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error RangeError
      end
    end
  end

  describe "#truncate", :aggregate_failures do
    context "when `digits` is 0" do
      it "truncates every coefficient to an Integer" do
        expect(zero_number.truncate(0)).to eql num
        expect(real_number.truncate).to eql num(999)
        expect(complex_number.truncate).to eql num(0, -13i)
        expect(composite_number.truncate).to eql num("y", :a, 8, 6i)
        expect((composite_number / 2).truncate).to eql num(4, 3i)
      end
    end

    context "when digits is > 0" do
      it "truncates excess decimal precision" do
        expect(zero_number.truncate(1)).to eql num
        expect(real_number.truncate(1)).to eql num(999.1)
        expect(complex_number.truncate(1)).to eql num(0.1, -13.4i)
        expect(composite_number.truncate(1)).to eql num("y", :a, 8, 6.3i)
        expect((composite_number / 3).truncate(1).to_a).to contain_exactly(
          ["y", 0.3r], [:a, 0.3r], [VectorNumber::R, 2.6], [VectorNumber::I, 2.1]
        )
      end
    end
  end
end
