# frozen_string_literal: true

require "bigdecimal"

RSpec.describe Kernel do
  let(:zero_number) { num }
  let(:real_number) { num(999.13) }
  let(:complex_number) { num(Complex(0.1, -13.3), -0.1i) }
  let(:composite_number) { num("y", :a, 5, Complex(3, 5), 1.3.i) }

  describe "#Integer" do
    let(:conversion) { Integer(number) }

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

  describe "#Float" do
    let(:conversion) { Float(number) }

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

  describe "#Rational" do
    let(:conversion) { Rational(number) }

    context "with zero" do
      let(:number) { zero_number }

      it "returns value as a Rational" do
        expect(conversion).to eql 0.0r
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

  describe "#BigDecimal" do
    let(:conversion) { BigDecimal(number) }

    context "with any vector number" do
      let(:number) { [zero_number, real_number, complex_number, composite_number].sample }

      it "raises an error" do
        expect { conversion }.to raise_error TypeError
      end
    end
  end

  describe "#Complex" do
    let(:conversion) { Complex(number) }

    context "with zero" do
      let(:number) { zero_number }

      it "returns value as a Complex" do
        expect(conversion).to eql Complex(0)
      end
    end

    context "with real number" do
      let(:number) { real_number }

      it "returns value as a Complex" do
        expect(conversion).to eql Complex(999.13)
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
end
