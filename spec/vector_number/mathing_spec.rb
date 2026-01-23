# frozen_string_literal: true

RSpec.describe VectorNumber, :aggregate_failures do
  let(:zero_number) { num(Complex(0, 0), 0.0, 1, -1) }
  let(:real_number) { num(-1.5r) }
  let(:composite_number) { num("y", :a, 5) }
  let(:f_number) { num("f") }

  describe "#coerce" do
    subject(:result) { number.coerce(other) }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    context "when other value is a VectorNumber" do
      let(:other) { num(rand) }

      it "returns array with other value and self unchanged" do
        # This expectation depends on Comparing#==.
        expect(result).to eq [other, number]
        # Check that these are actually the same objects, not just equal ones.
        expect(result.first).to be other
        expect(result.last).to be number
      end
    end

    context "when other value is a number" do
      let(:other) { [5, 55.55, 5/55r].sample }

      it "returns array with vectorized other value and self" do
        expect(result).to eq [num(other), number]
        expect(result.first.units).to eq [VectorNumber::R]
      end
    end

    context "when other value is NaN" do
      let(:other) { Float::NAN }

      it "returns array with vectorized NaN and self" do
        # NaN is not equal to NaN.
        expect(result.first.units).to eq [VectorNumber::R]
        expect(result.first.coefficients.first).to be_nan
        expect(result.last).to be number
      end
    end

    context "when other value is an Array" do
      let(:other) { [rand, rand, rand, rand] }

      it "returns array with vectorized other value and self" do
        expect(result).to eq [num(other), number]
        expect(result.first.units).to eq [other]
      end
    end

    context "when other value is a Hash" do
      let(:other) { { rand => rand, rand(10) => rand } }

      it "returns array with vectorized other value and self" do
        expect(result).to eq [num(other), number]
        expect(result.first.units).to eq [other]
      end
    end

    context "when other value is whatever else" do
      let(:other) { [Object.new, "myself", :vector, 1.upto(2)].sample }

      it "returns array with vectorized other value and self" do
        expect(result).to eq [num(other), number]
        expect(result.first.units).to eq [other]
      end
    end

    context "if number has non-default options" do
      let(:number) { num(rand, rand.i, "coerce", mult: :cross) }

      context "when other value is a VectorNumber" do
        let(:other) { num(rand, mult: :blank) }

        it "leaves options as-is for both" do
          expect(result.first.options).to eq(mult: :blank)
          expect(result.last.options).to eq(mult: :cross)
        end
      end

      context "when other value is anything else" do
        let(:other) { [-33, Object.new, "myself", :vector, 1.upto(2)].sample }

        it "propagates options to the new vector" do
          expect(result.first.options).to eq(mult: :cross)
          expect(result.last.options).to eq(mult: :cross)
        end
      end
    end
  end

  shared_examples "options propagation" do
    context "when number has non-default options" do
      let(:number) { num(rand.i, mult: "mult") }
      let(:other) { num(rand * rand, mult: "ult") }

      it "propagates first vector's options to the result" do
        # `eq` would be mostly sufficient,
        # but we also optimize options to be the same hash.
        expect(result.options).to be number.options
      end
    end
  end

  describe "#-@" do
    subject(:result) { -number }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    include_examples "options propagation"

    it "returns a new number with all coefficients negated" do
      expect(result.units).to eq number.units
      expect(result.coefficients).to eq number.coefficients.map(&:-@)
    end
  end

  include_examples "has an alias", :neg, :-@

  describe "#+" do
    subject(:result) { number + other }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    include_examples "options propagation"

    context "when adding a real number" do
      let(:other) { [rand(1.0..2.0), rand(1..10_000), rand(1r..100r)].sample }
      let(:result_array) do
        values = number.to_a
        values.delete(values.assoc(VectorNumber::R))
        values << [VectorNumber::R, number.real + other.real]
      end

      it "creates a new number, adding real number to real part" do
        expect(result.units).to match_array(number.units | [VectorNumber::R])
        expect(result.to_a).to match_array result_array
      end

      context "if adding a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, adding real number to real part" do
          expect(result.units).to match_array(number.units | [VectorNumber::R])
          expect(result.to_a).to match_array result_array
        end
      end
    end

    context "when adding to a real number" do
      subject(:result) { other + number }

      let(:other) { [rand(1.0..2.0), rand(1..10_000), rand(1r..100r)].sample }
      let(:result_array) do
        values = number.to_a
        values.delete(values.assoc(VectorNumber::R))
        values << [VectorNumber::R, number.real + other.real]
      end

      it "creates a new number, adding real number to real part" do
        expect(result.units).to match_array(number.units | [VectorNumber::R])
        expect(result.to_a).to match_array result_array
      end

      context "if adding to a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, adding real number to real part" do
          expect(result.units).to match_array(number.units | [VectorNumber::R])
          expect(result.to_a).to match_array result_array
        end
      end
    end

    context "when adding a complex number" do
      let(:other) { Complex(rand(-1000..-8), rand(10.0..1000.0)) }
      let(:result_array) do
        values = number.to_a
        values.delete(values.assoc(VectorNumber::R))
        values.delete(values.assoc(VectorNumber::I))
        values << [VectorNumber::R, number.real + other.real]
        values << [VectorNumber::I, number.imag + other.imag]
      end

      it "creates a new number, adding real part and imaginary parts together correspondingly" do
        expect(result.units).to match_array(number.units | [VectorNumber::R, VectorNumber::I])
        expect(result.to_a).to match_array result_array
      end
    end

    context "when adding to a complex number" do
      subject(:result) { other + number }

      let(:other) { Complex(rand(-1000..-8), rand(10.0..1000.0)) }
      let(:result_array) do
        values = number.to_a
        values.delete(values.assoc(VectorNumber::R))
        values.delete(values.assoc(VectorNumber::I))
        values << [VectorNumber::R, number.real + other.real]
        values << [VectorNumber::I, number.imag + other.imag]
      end

      it "creates a new number, adding real part and imaginary parts together correspondingly" do
        expect(result.units).to match_array(number.units | [VectorNumber::R, VectorNumber::I])
        expect(result.to_a).to match_array result_array
      end
    end

    context "when adding a vector number" do
      let(:other) { num(:foo, :bar) }

      it "adds the two vectors together" do
        expect(result.units).to match_array(number.units << :foo << :bar)
        expect(result.to_a).to match_array(number.to_a << [:foo, 1] << [:bar, 1])
      end
    end

    context "when adding an array" do
      let(:other) { [1, 2, 3, rand, Object.new, {}, []].take(3) }

      it "adds the array as a new unit" do
        expect(result.units).to match_array(number.units << other)
        expect(result.to_a).to match_array(number.to_a << [other, 1])
      end
    end

    context "when adding a hash" do
      let(:other) { { VectorNumber::R => 5 } }

      it "adds the hash as a new unit" do
        expect(result.units).to match_array(number.units << other)
        expect(result.to_a).to match_array(number.to_a << [other, 1])
      end
    end

    context "when adding any random value" do
      let(:other) { [Object.new, Class, described_class, :foo, binding].sample }

      it "adds the object as a new unit" do
        expect(result.units).to match_array(number.units << other)
        expect(result.to_a).to match_array(number.to_a << [other, 1])
      end

      context "when adding the same value again" do
        subject(:result) { number + other + other }

        it "adds two of the same value" do
          expect(result.units).to match_array(number.units << other)
          expect(result.to_a).to match_array(number.to_a << [other, 2])
        end
      end
    end
  end

  include_examples "has an alias", :add, :+

  describe "#-" do
    subject(:result) { number - other }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    include_examples "options propagation"

    context "when subtracting a real number" do
      let(:other) { [rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }
      let(:result_array) do
        values = number.to_a
        values.delete(values.assoc(VectorNumber::R))
        values << [VectorNumber::R, number.real - other.real]
      end

      it "creates a new number, subtracting real number from real part" do
        expect(result.units).to match_array(number.units | [VectorNumber::R])
        expect(result.to_a).to match_array result_array
      end

      context "if subtracting a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, subtracting real number from real part" do
          expect(result.units).to match_array(number.units | [VectorNumber::R])
          expect(result.to_a).to match_array result_array
        end
      end
    end

    context "when subtracting from a real number" do
      subject(:result) { other - number }

      let(:other) { [rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }
      let(:result_array) do
        values = number.to_a
        values.delete(values.assoc(VectorNumber::R))
        values << [VectorNumber::R, number.real - other.real]
        values.map { |u, c| [u, -c] }
      end

      it "creates a new number, subtracting real number from real part" do
        expect(result.units).to match_array(number.units | [VectorNumber::R])
        expect(result.to_a).to match_array result_array
      end

      context "if subtracting from a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, subtracting real number from real part" do
          expect(result.units).to match_array(number.units | [VectorNumber::R])
          expect(result.to_a).to match_array result_array
        end
      end
    end

    context "when subtracting a complex number" do
      let(:other) { Complex(rand(31..32), rand(0.5..555.5)) }
      let(:result_array) do
        values = number.to_a
        values.delete(values.assoc(VectorNumber::R))
        values.delete(values.assoc(VectorNumber::I))
        values << [VectorNumber::R, number.real - other.real]
        values << [VectorNumber::I, number.imag - other.imag]
      end

      it "creates a new number, subtracting real and imaginary parts correspondingly" do
        expect(result.units).to match_array(number.units | [VectorNumber::R, VectorNumber::I])
        expect(result.to_a).to match_array result_array
      end
    end

    context "when subtracting from a complex number" do
      subject(:result) { other - number }

      let(:other) { Complex(rand(31..32), rand(0.5..555.5)) }
      let(:result_array) do
        values = number.to_a
        values.delete(values.assoc(VectorNumber::R))
        values.delete(values.assoc(VectorNumber::I))
        values << [VectorNumber::R, number.real - other.real]
        values << [VectorNumber::I, number.imag - other.imag]
        values.map { |u, c| [u, -c] }
      end

      it "creates a new number, subtracting real part and imaginary parts correspondingly" do
        expect(result.units).to match_array(number.units | [VectorNumber::R, VectorNumber::I])
        expect(result.to_a).to match_array result_array
      end
    end

    context "when subtracting a vector number" do
      let(:other) { num(:foo, :bar) }

      it "subtracts the seconds vector from the first" do
        expect(result.units).to match_array(number.units << :foo << :bar)
        expect(result.to_a).to match_array(number.to_a << [:foo, -1] << [:bar, -1])
      end
    end

    context "when subtracting an array" do
      let(:other) { [1, 2, 3, rand, Object.new, {}, []].take(3) }

      it "subtracts the array as a new unit" do
        expect(result.units).to match_array(number.units << other)
        expect(result.to_a).to match_array(number.to_a << [other, -1])
      end
    end

    context "when subtracting a hash" do
      let(:other) { { VectorNumber::R => 5 } }

      it "subtracts the hash as a new unit" do
        expect(result.units).to match_array(number.units << other)
        expect(result.to_a).to match_array(number.to_a << [other, -1])
      end
    end

    context "when subtracting any random value" do
      let(:other) { [Object.new, Class, described_class, :foo, binding].sample }

      it "subtracts the object as a new unit" do
        expect(result.units).to match_array(number.units << other)
        expect(result.to_a).to match_array(number.to_a << [other, -1])
      end

      context "when subtracting the same value two times" do
        subject(:result) { number - other - other }

        it "subtracts two of the same value" do
          expect(result.units).to match_array(number.units << other)
          expect(result.to_a).to match_array(number.to_a << [other, -2])
        end
      end

      context "when adding and subtracting the same value" do
        it "creates a new number equal to the original, irrespective of operation order" do
          expect(number + other - other).to eq number
          expect(number - other + other).to eq number
        end
      end
    end
  end

  include_examples "has an alias", :sub, :-

  describe "#*" do
    subject(:result) { number * other }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    include_examples "options propagation"

    context "when multiplying by a real number" do
      let(:other) { [-rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }

      it "creates a new number, multiplying all coefficients by the other number" do
        expect(result.units).to eq number.units
        expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v * other] })
      end

      context "if multiplying by a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, multiplying all coefficients by the other number" do
          expect(result.units).to eq number.units
          expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v * other] })
        end
      end
    end

    context "when multiplying by a real vector number" do
      let(:other) { num(value) }
      let(:value) { [-rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }

      it "creates a new number, multiplying all coefficients by the value of the other number" do
        expect(result.units).to eq number.units
        expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v * value] })
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, multiplying all coefficients by the value of the other number" do
          expect(result.units).to eq number.units
          expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v * other] })
        end
      end
    end

    context "when multiplying non-real by a non-real vector_number" do
      let(:number) { [composite_number, f_number].sample }
      let(:other) { [composite_number, f_number].sample }

      it "raises RangeError" do
        expect { result }.to raise_error RangeError
      end
    end

    context "when multiplying by any other value" do
      let(:other) do
        [Complex(rand, rand(1..5)), Object.new, described_class, :foo, binding, [1]].sample
      end

      it "raises RangeError" do
        expect { result }.to raise_error RangeError
      end
    end

    context "when multiplying real number by a real vector number" do
      let(:number) { [-rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }

      let(:other) { num(value) }
      let(:value) { [-rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }

      it "returns a real result as a vector number" do
        expect(result).to be_a(described_class)
        expect(result.to_a).to eq [[VectorNumber::R, number * value]]
      end

      context "if multiplying a BigDecimal", :bigdecimal do
        let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a real result as a vector number" do
          expect(result).to be_a(described_class)
          expect(result.to_a).to eq [[VectorNumber::R, number * value]]
        end
      end
    end

    context "when multiplying real number by a non-real vector number" do
      let(:number) { [-rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }

      let(:other) { [composite_number, f_number, num(1, -15i)].sample }

      it "returns vector multiplied by the real number" do
        expect(result).to be_a(described_class)
        expect(result).to eq other * number
      end

      context "if multiplying a BigDecimal", :bigdecimal do
        let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns vector multiplied by the real number" do
          expect(result).to be_a(described_class)
          expect(result).to eq other * number
        end
      end
    end
  end

  include_examples "has an alias", :mult, :*

  shared_examples "invalid division" do
    context "when dividing by any non-real-number value" do
      let(:other) do
        [Complex(rand, rand(1..5)), Object.new, described_class, :foo, binding, [1]].sample
      end

      it "raises RangeError" do
        expect { result }.to raise_error RangeError
      end
    end

    context "when dividing by non-real vector number" do
      let(:other) { num(:s) }

      it "raises RangeError" do
        expect { result }.to raise_error RangeError
      end
    end

    context "when dividing by 0" do
      let(:other) { [0, 0.0, 0r].sample }

      it "raises ZeroDivisionError" do
        expect { result }.to raise_error ZeroDivisionError
      end

      context "when dividing by BigDecimal 0", :bigdecimal do
        let(:other) { BigDecimal(0) }

        it "raises ZeroDivisionError" do
          expect { result }.to raise_error ZeroDivisionError
        end
      end
    end
  end

  describe "#/" do
    subject(:result) { number / other }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    include_examples "options propagation"
    include_examples "invalid division"

    context "when dividing by a real number" do
      let(:other) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      it "creates a new number, dividing all coefficients by the other number" do
        expect(result.units).to eq number.units
        expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v / other] })
      end

      context "if dividing by a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, dividing all coefficients by the value of the other number" do
          expect(result).to be_a(described_class)
          expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v / other] })
        end
      end
    end

    context "when dividing integer by an integer" do
      let(:number) { num(real_value, "string") }
      let(:real_value) { rand(1..10_000) }

      let(:other) { rand(1..10_000) }

      it "stores coefficient as a Rational" do
        expect(result.to_a).to contain_exactly(
          [VectorNumber::R, Rational(real_value, other)],
          ["string", Rational(1, other)]
        )
      end
    end

    context "when dividing by a real vector number" do
      let(:other) { num(value) }
      let(:value) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      it "creates a new number, dividing all coefficients by the value of the other number" do
        expect(result.units).to eq number.units
        expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v / value] })
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, dividing all coefficients by the value of the other number" do
          expect(result).to be_a(described_class)
          expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v / other] })
        end
      end
    end

    context "when dividing real number by a real vector number" do
      let(:number) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      let(:other) { num(value) }
      let(:value) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a real result as a vector number" do
        expect(result).to be_a described_class
        expect(result.to_a).to eq [[VectorNumber::R, number / value]]
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a real result as a vector number" do
          expect(result).to be_a(described_class)
          expect(result.to_a).to eq [[VectorNumber::R, number / value]]
        end
      end
    end

    context "when dividing real number by a non-real vector number" do
      let(:number) { [-rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }

      let(:other) { [composite_number, f_number, num(1, -15i)].sample }

      it "raises RangeError" do
        expect { result }.to raise_error RangeError
      end

      context "if dividing a BigDecimal", :bigdecimal do
        let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "raises RangeError" do
          expect { result }.to raise_error RangeError
        end
      end
    end
  end

  include_examples "has an alias", :quo, :/

  describe "#fdiv" do
    subject(:result) { number.fdiv(other) }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    include_examples "options propagation"
    include_examples "invalid division"

    context "when dividing by a real number" do
      let(:other) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      it "creates a new number, dividing all coefficients by the other number" do
        expect(result.units).to eq number.units
        expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v.fdiv(other)] })
      end

      context "if dividing by a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, dividing all coefficients by the other number" do
          expect(result).to be_a(described_class)
          expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v.fdiv(other)] })
        end
      end
    end

    context "when dividing integer by an integer" do
      let(:number) { num(real_value, "string") }
      let(:real_value) { rand(1..10_000) }

      let(:other) { rand(1..10_000) }

      it "stores coefficient as a Float" do
        expect(result.to_a).to contain_exactly(
          [VectorNumber::R, real_value.fdiv(other)],
          ["string", 1.0 / other]
        )
      end
    end

    context "when dividing by a real vector number" do
      let(:other) { num(value) }
      let(:value) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      it "creates a new number, dividing all coefficients by the value of the other number" do
        expect(result.units).to eq number.units
        expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v.fdiv(other)] })
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, dividing all coefficients by the value of the other number" do
          expect(result).to be_a(described_class)
          expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v.fdiv(other)] })
        end
      end
    end

    context "when dividing Integer by a real vector number" do
      let(:number) { rand(2..10) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a Float result" do
        expect(result).to eq number.fdiv(value)
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a Float result" do
          expect(result).to eq number.fdiv(value)
        end
      end
    end

    context "when dividing Float by a real vector number" do
      let(:number) { -rand(6.0..7.0) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a real result as a vector number" do
        expect(result).to be_a described_class
        expect(result.to_a).to eq [[VectorNumber::R, number.fdiv(value)]]
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a real result as a vector number" do
          expect(result).to be_a described_class
          expect(result.to_a).to eq [[VectorNumber::R, number.fdiv(value)]]
        end
      end
    end

    context "when dividing Rational by a real vector number" do
      let(:number) { rand(10r..100r) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a Float result" do
        expect(result).to eq number.fdiv(value)
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a Float result" do
          expect(result).to eq number.fdiv(value)
        end
      end
    end

    context "when dividing BigDecimal by a real vector number", :bigdecimal do
      let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a real result as a vector number" do
        expect(result).to be_a described_class
        expect(result.to_a).to eq [[VectorNumber::R, number.fdiv(value)]]
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a real result as a vector number" do
          expect(result).to be_a described_class
          expect(result.to_a).to eq [[VectorNumber::R, number.fdiv(value)]]
        end
      end
    end

    context "when dividing real number by a non-real vector number" do
      let(:number) { [-rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }

      let(:other) { [composite_number, f_number, num(1, -15i)].sample }

      it "raises RangeError" do
        expect { result }.to raise_error RangeError
      end

      context "if dividing a BigDecimal", :bigdecimal do
        let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "raises RangeError" do
          expect { result }.to raise_error RangeError
        end
      end
    end
  end

  describe "#div" do
    subject(:result) { number.div(other) }

    let(:number) { num(32.14, -123.45i, 128r / 9, :a, :a) }
    let(:other) { rand(-10.0..10.0) }

    include_examples "options propagation"
    include_examples "invalid division"

    it "calls #div on each component" do
      expect(result.to_a).to match_array([
        [VectorNumber::R, (32.14 + (128r / 9)).div(other)],
        [VectorNumber::I, -123.45.div(other)],
        [:a, 2.div(other)],
      ].reject { |(_u, c)| c.zero? })
    end

    it "is equal to ⌊a/b⌋" do
      expect(result).to eq (number / other).floor
    end

    context "when dividing Integer by a real vector number" do
      let(:number) { rand(2..10) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns quotient" do
        expect(result).to eq number.div(value)
      end
    end

    context "when dividing Float by a real vector number" do
      let(:number) { -rand(6.0..7.0) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns quotient" do
        expect(result).to eq number.div(value)
      end
    end

    context "when dividing Rational by a real vector number" do
      let(:number) { rand(10r..100r) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns quotient" do
        expect(result).to eq number.div(value)
      end
    end

    context "when dividing BigDecimal by a real vector number", :bigdecimal do
      let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns quotient" do
        expect(result).to eq number.div(value)
      end
    end
  end

  describe "#%" do
    subject(:result) { number % other }

    let(:number) { num(1.5, -1i, "sshshs", :a, :a) * -3.5 }
    let(:other) { rand(-10.0..10.0) }

    include_examples "options propagation"
    include_examples "invalid division"

    it "calls #% on each component" do
      expect(result.to_a).to match_array([
        [VectorNumber::R, -5.25 % other],
        [VectorNumber::I, 3.5 % other],
        ["sshshs", -3.5 % other],
        [:a, -7 % other],
      ].reject { |(_u, c)| c.zero? })
    end

    # This test requires smallish numbers, as multiplication is not precise.
    it "is equal to (a - b⌊a/b⌋)" do
      expect(result).to eq number - (other * (number / other).floor)
    end

    context "when dividing Integer by a real vector number" do
      let(:number) { rand(2..10) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns modulus" do
        expect(result).to eq number % value
      end
    end

    context "when dividing Float by a real vector number" do
      let(:number) { -rand(6.0..7.0) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns modulus" do
        expect(result).to eq number % value
      end
    end

    context "when dividing Rational by a real vector number" do
      let(:number) { rand(10r..100r) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns modulus" do
        expect(result).to eq number % value
      end
    end

    context "when dividing BigDecimal by a real vector number", :bigdecimal do
      let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns modulus" do
        expect(result).to eq number % value
      end
    end
  end

  include_examples "has an alias", :modulo, :%

  describe "#divmod" do
    subject(:result) { number.divmod(other) }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }
    let(:other) { rand(-10.0..10.0) }

    include_examples "invalid division"

    it "returns a tuple of #div and #% results" do
      expect(result).to eq [number.div(other), number % other]
    end
  end

  describe "#remainder" do
    subject(:result) { number.remainder(other) }

    let(:number) { num(1.5, -1i, "sshshs", :a, :a) * -3.5 }
    let(:other) { rand(-10.0..10.0) }

    include_examples "options propagation"
    include_examples "invalid division"

    it "calls #% on each component" do
      expect(result.to_a).to match_array([
        [VectorNumber::R, -5.25.remainder(other)],
        [VectorNumber::I, 3.5.remainder(other)],
        ["sshshs", -3.5.remainder(other)],
        [:a, -7.remainder(other)],
      ].reject { |(_u, c)| c.zero? })
    end

    # This test requires smallish numbers, as multiplication is not precise.
    it "is equal to (a - b⌊|a/b|⌋)" do
      expect(result).to eq number - (other * (number / other).truncate)
    end

    context "when dividing Integer by a real vector number" do
      let(:number) { rand(2..10) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns remainder" do
        expect(result).to eq number.remainder(value)
      end
    end

    context "when dividing Float by a real vector number" do
      let(:number) { -rand(6.0..7.0) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns remainder" do
        expect(result).to eq number.remainder(value)
      end
    end

    context "when dividing Rational by a real vector number" do
      let(:number) { rand(10r..100r) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns remainder" do
        expect(result).to eq number.remainder(value)
      end
    end

    context "when dividing BigDecimal by a real vector number", :bigdecimal do
      let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns remainder" do
        expect(result).to eq number.remainder(value)
      end
    end
  end
end
