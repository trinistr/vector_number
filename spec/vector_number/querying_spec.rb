# frozen_string_literal: true

RSpec.describe VectorNumber::Querying, :aggregate_failures do
  let(:null_number) { num }
  let(:zero_number) { num(0, 0.i) }
  let(:real_number) { num(1, 0.i) }
  let(:imaginary_number) { num(Math::PI.i) }
  let(:composite_number) { num(-10, nil, Object.new) }

  describe "#real?" do
    it "is always false" do
      expect(null_number).not_to be_real
      expect(zero_number).not_to be_real
      expect(real_number).not_to be_real
      expect(imaginary_number).not_to be_real
      expect(composite_number).not_to be_real
    end
  end

  describe "#numeric?" do
    context "with default argument of 2" do
      it "considers numbers which only contain real and imaginary parts to be numeric" do
        expect(null_number.numeric?).to be true
        expect(zero_number.numeric?).to be true
        expect(real_number.numeric?).to be true
        expect(imaginary_number.numeric?).to be true
        expect(composite_number.numeric?).to be false
      end
    end

    context "when dimensions = 0" do
      it "considers numbers which contain no parts to be numeric" do
        expect(null_number.numeric?(0)).to be true
        expect(zero_number.numeric?(0)).to be true
        expect(real_number.numeric?(0)).to be false
        expect(imaginary_number.numeric?(0)).to be false
        expect(composite_number.numeric?(0)).to be false
      end
    end

    context "when dimensions = 1" do
      it "considers numbers which contain only real part to be numeric" do
        expect(null_number.numeric?(1)).to be true
        expect(zero_number.numeric?(1)).to be true
        expect(real_number.numeric?(1)).to be true
        expect(imaginary_number.numeric?(1)).to be false
        expect(composite_number.numeric?(1)).to be false
      end
    end

    context "when dimensions > 2" do
      it "considers numbers which only contain real and imaginary parts to be numeric" do
        expect(null_number.numeric?(3)).to be true
        expect(zero_number.numeric?(3)).to be true
        expect(real_number.numeric?(3)).to be true
        expect(imaginary_number.numeric?(3)).to be true
        expect(composite_number.numeric?(3)).to be false
      end
    end
  end

  describe "#finite?" do
    context "when no coefficients are infinite" do
      it "is true" do
        expect(null_number).to be_finite
        expect(zero_number).to be_finite
        expect(real_number).to be_finite
        expect(imaginary_number).to be_finite
        expect(composite_number).to be_finite
      end
    end

    context "when any coefficients are infinite" do
      it "is false" do
        expect(num(Float::INFINITY)).not_to be_finite
        expect(num(Float::NAN, "a")).not_to be_finite
        expect(num(-Float::INFINITY, 4.i)).not_to be_finite
      end
    end
  end

  describe "#infinite?" do
    context "when no coefficients are infinite" do
      it "returns nil" do
        expect(null_number.infinite?).to be_nil
        expect(zero_number.infinite?).to be_nil
        expect(real_number.infinite?).to be_nil
        expect(imaginary_number.infinite?).to be_nil
        expect(composite_number.infinite?).to be_nil
      end
    end

    context "when any coefficients are infinite" do
      it "returns 1" do
        expect(num(Float::INFINITY).infinite?).to be 1
        expect(num(Float::NAN, "a").infinite?).to be 1
        expect(num(-Float::INFINITY, 4.i).infinite?).to be 1
      end
    end
  end

  describe "#zero?" do
    context "when all coefficients are zero" do
      it "is true" do
        expect(null_number).to be_zero
        expect(zero_number).to be_zero
      end
    end

    context "when any coefficients are non-zero" do
      it "is false" do
        expect(real_number).not_to be_zero
        expect(imaginary_number).not_to be_zero
        expect(composite_number).not_to be_zero
      end
    end
  end

  describe "#nonzero?" do
    context "when all coefficients are zero" do
      it "returns nil" do
        expect(null_number.nonzero?).to be_nil
        expect(zero_number.nonzero?).to be_nil
      end
    end

    context "when any coefficients are non-zero" do
      it "returns the number" do
        expect(real_number.nonzero?).to be real_number
        expect(imaginary_number.nonzero?).to be imaginary_number
        expect(composite_number.nonzero?).to be composite_number
      end
    end
  end

  describe "#positive?" do
    context "when all coefficients are positive" do
      it "is true" do
        expect(real_number).to be_positive
        expect(imaginary_number).to be_positive
      end
    end

    context "when all coefficients are zero or negative" do
      it "is false" do
        expect(null_number).not_to be_positive
        expect(zero_number).not_to be_positive
        expect(num(-13)).not_to be_positive
        expect(num(Complex(-6.1, -0.2))).not_to be_positive
      end
    end

    context "when coefficients are both positive and negative" do
      it "returns nil" do
        expect(composite_number.positive?).to be_nil
      end
    end
  end

  describe "#negative?" do
    context "when all coefficients are zero or positive" do
      it "is false" do
        expect(null_number).not_to be_negative
        expect(zero_number).not_to be_negative
        expect(real_number).not_to be_negative
        expect(imaginary_number).not_to be_negative
      end
    end

    context "when all coefficients are negative" do
      it "is true" do
        expect(num(-13)).to be_negative
        expect(num(Complex(-6.1, -0.2))).to be_negative
      end
    end

    context "when coefficients are both positive and negative" do
      it "returns nil" do
        expect(composite_number.positive?).to be_nil
      end
    end
  end
end
