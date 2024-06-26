# frozen_string_literal: true

require "bigdecimal"

# Starting with Ruby 3.2, Integer() behavior changed, and #to_str is called before #to_int.
ruby_3_2_test_object = Object.new
class << ruby_3_2_test_object
  def to_int
    raise RangeError
  end
  alias to_i to_int

  def to_str
    "abcd"
  end
end
integer_exception_class =
  begin
    Integer(ruby_3_2_test_object)
  rescue RangeError, ArgumentError => e
    e.class
  end

RSpec.describe Kernel do
  let(:zero_number) { num }
  let(:real_number) { num(999.13) }
  let(:complex_number) { num(Complex(0.1, -13.3), -0.1i) }
  let(:composite_number) { num("y", :a, 5, Complex(3, 5), 1.3.i) }

  describe ".Integer" do
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

      it "raises #{integer_exception_class}" do
        expect { conversion }.to raise_error integer_exception_class
      end
    end

    context "with composite number" do
      let(:number) { composite_number }

      it "raises #{integer_exception_class}" do
        expect { conversion }.to raise_error integer_exception_class
      end
    end
  end

  describe ".Float" do
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

  describe ".Rational" do
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

  describe ".BigDecimal" do
    let(:conversion) { BigDecimal(number) }

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
        expect { conversion }.to raise_error ArgumentError
      end
    end

    context "with composite number" do
      let(:number) { composite_number }

      it "raises RangeError" do
        expect { conversion }.to raise_error ArgumentError
      end
    end
  end

  describe ".Complex" do
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
