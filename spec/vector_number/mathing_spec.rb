# frozen_string_literal: true

RSpec.describe VectorNumber::Mathing, :aggregate_failures do
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
        expect(result.first).to be other
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

    context "when other value is anything else" do
      let(:other) { [Object.new, [1], "myself", Float::DIG].sample }

      it "returns array with vectorized other value and self" do
        expect(result).to eq [num(other), number]
      end
    end

    context "when other value is NaN" do
      let(:other) { [Float::NAN].sample }

      it "returns array with vectorized NaN and self" do
        # NaN is not equal to NaN.
        expect(result.first.units.first).to be VectorNumber::R
        expect(result.first.coefficients.first).to be_nan
        expect(result.last).to be number
      end
    end
  end

  describe "#+@" do
    subject(:result) { +number }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    it "returns the number itself" do
      expect(result).to be number
    end
  end

  describe "#-@" do
    subject(:result) { -number }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    it "returns a new number with all coefficients negated" do
      expect(result.units).to eq number.units
      expect(result.coefficients).to eq number.coefficients.map(&:-@)
    end
  end

  describe "#+" do
    subject(:result) { number + other }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    context "when adding a real number" do
      let(:other) { [rand(1.0..2.0), rand(1..10_000), rand(1r..100r)].sample }
      let(:result_array) do
        values = number.to_a
        if (value = values.assoc(VectorNumber::R))
          value[1] += other.real
        else
          values << [VectorNumber::R, other.real]
        end
        values
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
        if (value = values.assoc(VectorNumber::R))
          value[1] += other.real
        else
          values << [VectorNumber::R, other.real]
        end
        values
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
        if (value = values.assoc(VectorNumber::R))
          value[1] += other.real
        else
          values << [VectorNumber::R, other.real]
        end
        if (value = values.assoc(VectorNumber::I))
          value[1] += other.imag
        else
          values << [VectorNumber::I, other.imag]
        end
        values
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
        if (value = values.assoc(VectorNumber::R))
          value[1] += other.real
        else
          values << [VectorNumber::R, other.real]
        end
        if (value = values.assoc(VectorNumber::I))
          value[1] += other.imag
        else
          values << [VectorNumber::I, other.imag]
        end
        values
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
      let(:other) { [Object.new, Class, VectorNumber, :foo, binding].sample }

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

  describe "#-" do
    subject(:result) { number - other }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    context "when subtracting a real number" do
      let(:other) { [rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }
      let(:result_array) do
        values = number.to_a
        if (value = values.assoc(VectorNumber::R))
          value[1] -= other.real
        else
          values << [VectorNumber::R, -other.real]
        end
        values
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
        if (value = values.assoc(VectorNumber::R))
          value[1] -= other.real
        else
          values << [VectorNumber::R, -other.real]
        end
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
        if (value = values.assoc(VectorNumber::R))
          value[1] -= other.real
        else
          values << [VectorNumber::R, -other.real]
        end
        if (value = values.assoc(VectorNumber::I))
          value[1] -= other.imag
        else
          values << [VectorNumber::I, -other.imag]
        end
        values
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
        if (value = values.assoc(VectorNumber::R))
          value[1] -= other.real
        else
          values << [VectorNumber::R, -other.real]
        end
        if (value = values.assoc(VectorNumber::I))
          value[1] -= other.imag
        else
          values << [VectorNumber::I, -other.imag]
        end
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
      let(:other) { [Object.new, Class, VectorNumber, :foo, binding].sample }

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

  describe "#*" do
    subject(:result) { number * other }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

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
        [Complex(rand, rand(1..5)), Object.new, VectorNumber, :foo, binding, [1]].sample
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
        expect(result).to be_a(VectorNumber)
        expect(result.to_a).to eq [[VectorNumber::R, number * value]]
      end

      context "if multiplying a BigDecimal", :bigdecimal do
        let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a real result as a vector number" do
          expect(result).to be_a(VectorNumber)
          expect(result.to_a).to eq [[VectorNumber::R, number * value]]
        end
      end
    end

    context "when multiplying real number by a non-real vector number" do
      let(:number) { [-rand(6.0..7.0), rand(13..10_000), rand(10r..100r)].sample }

      let(:other) { [composite_number, f_number, num(1, -15i)].sample }

      it "returns vector multiplied by the real number" do
        expect(result).to be_a(VectorNumber)
        expect(result).to eq other * number
      end

      context "if multiplying a BigDecimal", :bigdecimal do
        let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns vector multiplied by the real number" do
          expect(result).to be_a(VectorNumber)
          expect(result).to eq other * number
        end
      end
    end
  end

  describe "#/" do
    subject(:result) { number / other }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    context "when dividing by a real number" do
      let(:other) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      it "creates a new number, dividing all coefficients by the other number" do
        expect(result.units).to eq number.units
        expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v / other] })
      end

      context "if dividing by a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, dividing all coefficients by the value of the other number" do
          expect(result).to be_a(VectorNumber)
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
          expect(result).to be_a(VectorNumber)
          expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v / other] })
        end
      end
    end

    context "when dividing by any other value" do
      let(:other) do
        [Complex(rand, rand(1..5)), Object.new, VectorNumber, :foo, binding, [1]].sample
      end

      it "raises RangeError" do
        expect { result }.to raise_error RangeError
      end
    end

    context "when dividing real number by a real vector number" do
      let(:number) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      let(:other) { num(value) }
      let(:value) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a real result as a vector number" do
        expect(result).to be_a VectorNumber
        expect(result.to_a).to eq [[VectorNumber::R, number / value]]
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a real result as a vector number" do
          expect(result).to be_a(VectorNumber)
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

  include_examples "has an alias", :quo, :/

  describe "#fdiv" do
    subject(:result) { number.fdiv(other) }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }

    context "when dividing by a real number" do
      let(:other) { [-rand(6.0..7.0), rand(10r..100r)].sample }

      it "creates a new number, dividing all coefficients by the other number" do
        expect(result.units).to eq number.units
        expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v.fdiv(other)] })
      end

      context "if dividing by a BigDecimal", :bigdecimal do
        let(:other) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "creates a new number, dividing all coefficients by the other number" do
          expect(result).to be_a(VectorNumber)
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
          expect(result).to be_a(VectorNumber)
          expect(result.to_a).to eq(number.to_a.map { |k, v| [k, v.fdiv(other)] })
        end
      end
    end

    context "when dividing by any other value" do
      let(:other) do
        [Complex(rand, rand(1..5)), Object.new, VectorNumber, :foo, binding, [1]].sample
      end

      it "raises RangeError" do
        expect { result }.to raise_error RangeError
      end
    end

    context "when dividing Float by a real vector number" do
      let(:number) { -rand(6.0..7.0) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a real result as a vector number" do
        expect(result).to be_a VectorNumber
        expect(result.to_a).to eq [[VectorNumber::R, number.fdiv(value)]]
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a real result as a vector number" do
          expect(result).to be_a VectorNumber
          expect(result.to_a).to eq [[VectorNumber::R, number.fdiv(value)]]
        end
      end
    end

    context "when dividing BigDecimal by a real vector number", :bigdecimal do
      let(:number) { rand(BigDecimal("-100")..BigDecimal("-10")) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a real result as a vector number" do
        expect(result).to be_a VectorNumber
        expect(result.to_a).to eq [[VectorNumber::R, number.fdiv(value)]]
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a real result as a vector number" do
          expect(result).to be_a VectorNumber
          expect(result.to_a).to eq [[VectorNumber::R, number.fdiv(value)]]
        end
      end
    end

    context "when dividing Integer by a real vector number" do
      let(:number) { rand(2..10) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a Float result" do
        expect(result).to be_a Float
        expect(result).to eq number.fdiv(value)
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a Float result" do
          expect(result).to be_a Float
          expect(result).to eq number.fdiv(value)
        end
      end
    end

    context "when dividing Rational by a real vector number" do
      let(:number) { rand(10r..100r) }

      let(:other) { num(value) }
      let(:value) { [rand(2..10), -rand(6.0..7.0), rand(10r..100r)].sample }

      it "returns a Float result" do
        expect(result).to be_a Float
        expect(result).to eq number.fdiv(value)
      end

      context "if vector contains a BigDecimal", :bigdecimal do
        let(:value) { rand(BigDecimal("-100")..BigDecimal("-10")) }

        it "returns a Float result" do
          expect(result).to be_a Float
          expect(result).to eq number.fdiv(value)
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

  describe "#div" do
    let(:result) { number.div(other) }

    let(:number) { num(32.14, -123.45i, 128r / 9, :a, :a) }
    let(:other) { rand(-10.0..10.0) }

    it "calls #div on each component" do
      expect(result.to_a).to match_array([
        [VectorNumber::R, (32.14 + (128r / 9)).div(other)],
        [VectorNumber::I, -123.45.div(other)],
        [:a, 2.div(other)]
      ].reject { |(_u, c)| c.zero? })
    end

    it "is equal to ⌊a/b⌋" do
      expect(result).to eq (number / other).floor
    end

    context "when dividing by any non-real value" do
      let(:other) do
        [Complex(rand, rand(1..5)), Object.new, VectorNumber, :foo, binding, [1]].sample
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

  describe "#%" do
    let(:result) { number % other }

    let(:number) { num(1.5, -1i, "sshshs", :a, :a) * -3.5 }
    let(:other) { rand(-10.0..10.0) }

    it "calls #% on each component" do
      expect(result.to_a).to match_array([
        [VectorNumber::R, -5.25 % other],
        [VectorNumber::I, 3.5 % other],
        ["sshshs", -3.5 % other],
        [:a, -7 % other]
      ].reject { |(_u, c)| c.zero? })
    end

    # This test requires smallish numbers, as multiplication is not precise.
    it "is equal to (a - b⌊a/b⌋)" do
      expect(result).to eq number - (other * (number / other).floor)
    end

    context "when dividing by any non-real value" do
      let(:other) do
        [Complex(rand, rand(1..5)), Object.new, VectorNumber, :foo, binding, [1]].sample
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

  include_examples "has an alias", :modulo, :%

  describe "#divmod" do
    let(:result) { number.divmod(other) }

    let(:number) { [zero_number, real_number, composite_number, f_number].sample }
    let(:other) { rand(-10.0..10.0) }

    it "returns a tuple of #div and #% results" do
      expect(result).to eq [number.div(other), number % other]
    end
  end

  describe "#remainder" do
    let(:result) { number.remainder(other) }

    let(:number) { num(1.5, -1i, "sshshs", :a, :a) * -3.5 }
    let(:other) { rand(-10.0..10.0) }

    it "calls #% on each component" do
      expect(result.to_a).to match_array([
        [VectorNumber::R, -5.25.remainder(other)],
        [VectorNumber::I, 3.5.remainder(other)],
        ["sshshs", -3.5.remainder(other)],
        [:a, -7.remainder(other)]
      ].reject { |(_u, c)| c.zero? })
    end

    # This test requires smallish numbers, as multiplication is not precise.
    it "is equal to (a - b⌊|a/b|⌋)" do
      expect(result).to eq number - (other * (number / other).truncate)
    end

    context "when dividing by any non-real value" do
      let(:other) do
        [Complex(rand, rand(1..5)), Object.new, VectorNumber, :foo, binding, [1]].sample
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
end
