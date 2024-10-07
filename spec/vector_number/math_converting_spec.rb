# frozen_string_literal: true

RSpec.describe VectorNumber::MathConverting do
  let(:zero_number) { num }
  let(:real_number) { num(999.15) }
  let(:complex_number) { num(Complex(0.12, -13.5)) }
  let(:composite_number) { num("y", :a, 5, Complex(3, 5), 1.3i) }

  describe "#abs", :aggregate_failures do
    it "returns magnitude of the vector as a Float" do
      expect(zero_number.abs).to be 0.0
      expect(real_number.abs).to be 999.15
      # These are exact values. Should be crossplatform too.
      expect(complex_number.abs).to be 13.50053332279877
      expect(composite_number.abs).to be 10.280564186852782
    end
  end

  include_examples "has an alias", :magnitude, :abs

  describe "#abs2", :aggregate_failures do
    it "returns square of the magnitude as a Float" do
      expect(zero_number.abs2).to be 0.0
      expect(real_number.abs2).to eq real_number.abs**2
      expect(complex_number.abs2).to eq complex_number.abs**2
      expect(composite_number.abs2).to eq composite_number.abs**2
    end
  end

  describe "#truncate", :aggregate_failures do
    context "when `digits` is 0" do
      it "truncates every coefficient to an Integer" do
        expect(zero_number.truncate).to eql num
        expect(real_number.truncate).to eql num(999)
        expect(complex_number.truncate).to eql num(-13i)
        expect(composite_number.truncate).to eql num("y", :a, 8, 6i)
        expect((composite_number / 2).truncate).to eql num(4, 3i)
      end
    end

    context "when digits is > 0" do
      it "truncates excess decimal precision, rounding to zero" do
        expect(zero_number.truncate(1)).to eql num
        expect(real_number.truncate(1)).to eql num(999.1)
        expect(complex_number.truncate(1)).to eql num(0.1, -13.5i)
        expect(composite_number.truncate(1)).to eql num("y", :a, 8, 6.3i)
        expect((composite_number / 3).truncate(1).to_a).to contain_exactly(
          ["y", 0.3r], [:a, 0.3r], [VectorNumber::R, 2.6], [VectorNumber::I, 2.1]
        )
      end
    end

    context "when digits is < 0" do
      it "truncates excess precision above 1, rounding to zero" do
        expect(zero_number.truncate(-1)).to eql num
        expect(real_number.truncate(-1)).to eql num(990)
        expect(complex_number.truncate(-1)).to eql num(-10i)
        expect(composite_number.truncate(-1)).to eql num
        expect((composite_number * 3).truncate(-1)).to eql num(20, 10i)
      end
    end
  end

  describe "#ceil", :aggregate_failures do
    context "when `digits` is 0" do
      it "rounds every coefficient up to an Integer" do
        expect(zero_number.ceil).to eql num
        expect(real_number.ceil).to eql num(1000)
        expect(complex_number.ceil).to eql num(1, -13i)
        expect(composite_number.ceil).to eql num("y", :a, 8, 7i)
        expect((composite_number / 2).ceil).to eql num("y", :a, 4, 4i)
      end
    end

    context "when digits is > 0" do
      it "truncates excess decimal precision, rounding up" do
        expect(zero_number.ceil(1)).to eql num
        expect(real_number.ceil(1)).to eql num(999.2)
        expect(complex_number.ceil(1)).to eql num(0.2, -13.5i)
        expect(composite_number.ceil(1)).to eql num("y", :a, 8, 6.3i)
        expect((composite_number / 3).ceil(1).to_a).to contain_exactly(
          ["y", 0.4r], [:a, 0.4r], [VectorNumber::R, 2.7], [VectorNumber::I, 2.1]
        )
      end
    end

    context "when digits is < 0" do
      it "truncates excess precision above 1, rounding up" do
        expect(zero_number.ceil(-1)).to eql num
        expect(real_number.ceil(-1)).to eql num(1000)
        expect(complex_number.ceil(-1)).to eql num(10, -10i)
        expect(composite_number.ceil(-1).to_a).to contain_exactly(
          ["y", 10], [:a, 10], [VectorNumber::R, 10], [VectorNumber::I, 10]
        )
        expect((composite_number / 3).ceil(-1).to_a).to contain_exactly(
          ["y", 10], [:a, 10], [VectorNumber::R, 10], [VectorNumber::I, 10]
        )
      end
    end
  end

  describe "#floor", :aggregate_failures do
    context "when `digits` is 0" do
      it "rounds every coefficient down to an Integer" do
        expect(zero_number.floor).to eql num
        expect(real_number.floor).to eql num(999)
        expect(complex_number.floor).to eql num(-14i)
        expect(composite_number.floor).to eql num("y", :a, 8, 6i)
        expect((composite_number / 2).floor).to eql num(4, 3i)
      end
    end

    context "when digits is > 0" do
      it "truncates excess decimal precision, rounding down" do
        expect(zero_number.floor(1)).to eql num
        expect(real_number.floor(1)).to eql num(999.1)
        expect(complex_number.floor(1)).to eql num(0.1, -13.5i)
        expect(composite_number.floor(1)).to eql num("y", :a, 8, 6.3i)
        expect((composite_number / 3).floor(1).to_a).to contain_exactly(
          ["y", 0.3r], [:a, 0.3r], [VectorNumber::R, 2.6], [VectorNumber::I, 2.1]
        )
      end
    end

    context "when digits is < 0" do
      it "truncates excess precision above 1, rounding down" do
        expect(zero_number.floor(-1)).to eql num
        expect(real_number.floor(-1)).to eql num(990)
        expect(complex_number.floor(-1)).to eql num(-20i)
        expect(composite_number.floor(-1)).to eql num
        expect((composite_number * 3).floor(-1)).to eql num(20, 10i)
      end
    end
  end

  describe "#round", :aggregate_failures do
    context "when `digits` is 0" do
      it "rounds every coefficient to an Integer, rounding up on half" do
        expect(zero_number.round).to eql num
        expect(real_number.round).to eql num(999)
        expect(complex_number.round).to eql num(-14i)
        expect(composite_number.round).to eql num("y", :a, 8, 6i)
        expect((composite_number / 2).round).to eql num("y", :a, 4, 3i)
      end
    end

    context "when digits is > 0" do
      it "truncates excess decimal precision, rounding up on half" do
        expect(zero_number.round(1)).to eql num
        expect(real_number.round(1)).to eql num(999.2)
        expect(complex_number.round(1)).to eql num(0.1, -13.5i)
        expect(composite_number.round(1)).to eql num("y", :a, 8, 6.3i)
        expect((composite_number / 3).round(1).to_a).to contain_exactly(
          ["y", 0.3r], [:a, 0.3r], [VectorNumber::R, 2.7], [VectorNumber::I, 2.1]
        )
      end
    end

    context "when digits is < 0" do
      it "truncates excess precision above 1, rounding up on half" do
        expect(zero_number.round(-1)).to eql num
        expect(real_number.round(-1)).to eql num(1000)
        expect(complex_number.round(-1)).to eql num(-10i)
        expect(composite_number.round(-1)).to eql num(10, 10i)
        expect((composite_number * 3).round(-1)).to eql num(20, 20i)
      end
    end

    context "with half: :up" do
      let(:number) { num(3.65i, :a) }

      it "rounds up on half" do
        expect(number.round(half: :up)).to eql num(4i, :a)
        expect(number.round(1, half: :up)).to eql num(3.7i, :a)
      end

      context "if a BigDecimal value is included", :bigdecimal do
        let(:number) { num(BigDecimal("1.5"), 3.65i, :a) }

        it "rounds up on half, using half_up for BigDecimal" do
          expect(number.round(half: :up)).to eql num(BigDecimal("2"), 4i, :a)
          expect(number.round(1, half: :up)).to eql num(BigDecimal("1.5"), 3.7i, :a)
        end
      end
    end

    context "with half: :down" do
      let(:number) { num(3.65i, :a) }

      it "rounds down on half" do
        expect(number.round(half: :down)).to eql num(4i, :a)
        expect(number.round(1, half: :down)).to eql num(3.6i, :a)
      end

      context "if a BigDecimal value is included", :bigdecimal do
        let(:number) { num(BigDecimal("1.5"), 3.65i, :a) }

        it "rounds down on half, using half_down for BigDecimal" do
          expect(number.round(half: :down)).to eql num(BigDecimal("1"), 4i, :a)
          expect(number.round(1, half: :down)).to eql num(BigDecimal("1.5"), 3.6i, :a)
        end
      end
    end

    context "with half: :even" do
      let(:number) { num(3.65i, :a) }

      it "rounds to even on half" do
        expect(number.round(half: :even)).to eql num(4i, :a)
        expect(number.round(1, half: :even)).to eql num(3.6i, :a)
      end

      context "if a BigDecimal value is included", :bigdecimal do
        let(:number) { num(BigDecimal("1.5"), 3.65i, :a) }

        it "rounds to even on half, using half_even for BigDecimal" do
          expect(number.round(half: :even)).to eql num(BigDecimal("2"), 4i, :a)
          expect(number.round(1, half: :even)).to eql num(BigDecimal("1.5"), 3.6i, :a)
        end
      end
    end
  end
end
