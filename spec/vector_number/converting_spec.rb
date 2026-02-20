# frozen_string_literal: true

RSpec.describe VectorNumber do
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

  include_examples "has an alias", :imag, :imaginary

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

  include_examples "has an alias", :to_int, :to_i

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

  describe "#to_d", :bigdecimal do
    subject(:conversion) { number.to_d }

    context "with zero" do
      let(:number) { zero_number }

      it "returns value as a BigDecimal" do
        expect(conversion).to eql BigDecimal(0)
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

    context "when ndigits argument is specified" do
      subject(:conversion) { number.to_d(1) }

      context "with real number" do
        let(:number) { real_number }

        it "returns value as a BigDecimal with specified precision" do
          expect(conversion).to eql BigDecimal(1000)
        end
      end
    end

    context "when BigDecimal is not available", bigdecimal: false do
      # There is no simple way to mock the method,
      # so we create a class which mocks unavailability.
      # Ditto for constant resolution.
      let(:test_class) do
        Class.new(VectorNumber) do
          undef_method :BigDecimal
          remove_const :BigDecimal
        end
      end

      context "with a number that could be converted" do
        let(:number) { test_class[0] }

        it "raises NameError" do
          expect { conversion }.to raise_error NameError
        end
      end

      context "with a number that could not be converted" do
        let(:number) { test_class[2i] }

        it "raises NameError" do
          expect { conversion }.to raise_error NameError
        end
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

  describe "#to_h" do
    subject(:hash) { number.to_h(&block) }

    let(:number) { composite_number }
    let(:block) { nil }

    context "without a block" do
      it "returns plain vector representation without calling #each" do
        # Can't actually test for not calling #each, as objects are frozen and can't be mocked.
        expect(hash).to eq(described_class::R => 8, described_class::I => 6.3, "y" => 1, :a => 1)
      end
    end

    context "with a block" do
      let(:block) { ->(u, v) { [u, described_class.numeric_unit?(u) ? v : v * 0.5] } }

      it "returns transformed plain vector representation" do
        expect(hash).to eq(
          described_class::R => 8, described_class::I => 6.3, "y" => 0.5, :a => 0.5
        )
      end
    end
  end
end
