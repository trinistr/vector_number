# frozen_string_literal: true

RSpec.describe VectorNumber::Comparing do
  let(:real_number) { num(567/120r) }
  let(:composite_number) { num("y", :a, 5) }

  describe "#==" do
    subject { (rand > 0.5) ? compared_number == other : other == compared_number }

    context "when comparing to itself" do
      let(:compared_number) { num([13, 8.7.i, "oui", "ya", Object.new].sample(3)) }
      let(:other) { compared_number }

      it { is_expected.to be true }
    end

    context "with a simple number" do
      let(:compared_number) { real_number }

      context "when comparing to an equal value of the same class" do
        let(:other) { num(567/120r) }

        it { is_expected.to be true }
      end

      context "when comparing to an equal value of a different class" do
        let(:other) { 567.fdiv(120) }

        it { is_expected.to be true }
      end

      context "when comparing to BigDecimal of an equal value", :bigdecimal do
        let(:other) { BigDecimal("567") / 120 }

        it { is_expected.to be true }
      end

      context "when comparing to a different value of the same class" do
        let(:other) { composite_number }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [5, "string", nil].sample }

        it { is_expected.to be false }
      end
    end

    context "with a complex number" do
      let(:compared_number) { num(1.8, 1ri / 2) }

      context "when comparing to an equal value of the same class" do
        let(:other) { num(1, 0.8, 0.5i) }

        it { is_expected.to be true }
      end

      context "when comparing to an equal value of a different class" do
        let(:other) { Complex(9r / 5, 0.5) }

        it { is_expected.to be true }
      end

      context "when comparing to a different value of the same class" do
        let(:other) { composite_number }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [5, "string", nil].sample }

        it { is_expected.to be false }
      end
    end

    context "with a composite number" do
      let(:compared_number) { composite_number }

      context "when every value is the same" do
        let(:other) { num("y", :a, 5) }

        it { is_expected.to be true }
      end

      context "when every value is the same but specified in a different order" do
        let(:other) { num(:a, 5, "y", 0.i) }

        it { is_expected.to be true }
      end

      context "when some values are not the same" do
        let(:other) { num("y", "a", 5) }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [5, "string", nil].sample }

        it { is_expected.to be false }
      end
    end
  end

  describe "#eql?" do
    subject { (rand > 0.5) ? compared_number.eql?(other) : other.eql?(compared_number) }

    context "when comparing to itself" do
      let(:compared_number) { num([13, 8.7.i, "oui", "ya", Object.new].sample(3)) }
      let(:other) { compared_number }

      it { is_expected.to be true }
    end

    context "with a simple number" do
      let(:compared_number) { real_number }

      context "when comparing to an equal value of the same class" do
        let(:other) { num(567/120r) }

        it { is_expected.to be true }
      end

      context "when comparing to an equal value of a different class" do
        let(:other) { 567/120r }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of the same class" do
        let(:other) { composite_number }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [5, "string", nil].sample }

        it { is_expected.to be false }
      end
    end

    context "with a composite number" do
      let(:compared_number) { composite_number }

      context "when every value is the same" do
        let(:other) { num("y", :a, 5) }

        it { is_expected.to be true }
      end

      context "when every value is the same but the order is different" do
        let(:other) { num(*["y", :a, 5].shuffle) }

        it { is_expected.to be true }
      end

      context "when numbers are initialized with different units, but extra coefficients are 0" do
        let(:other) { num(:a, 5, "y", 0.i) }

        it { is_expected.to be true }
      end

      context "when some values are not the same" do
        let(:other) { num("y", "a", 5) }

        it { is_expected.to be false }
      end

      context "when there are extra values" do
        let(:other) { num("y", "a", 5, "5") }

        it { is_expected.to be false }
      end

      context "when there are less values" do
        let(:other) { num("y", "a") }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [5, "string", nil].sample }

        it { is_expected.to be false }
      end
    end
  end

  describe "#<=>" do
    subject { forward_comparison ? compared_number <=> other : other <=> compared_number }

    let(:forward_comparison) { rand > 0.5 }

    context "with a simple number" do
      let(:compared_number) { real_number }

      context "when comparing to a larger value of the same class" do
        let(:other) { num(567) }
        let(:result) { forward_comparison ? -1 : 1 }

        it { is_expected.to be result }
      end

      context "when comparing to a smaller value of a different class" do
        let(:other) { 567.fdiv(1200) }
        let(:result) { forward_comparison ? 1 : -1 }

        it { is_expected.to be result }
      end

      context "when comparing to an equal value" do
        let(:other) { [num(567r / 120), 567.0 / 120].sample }

        it { is_expected.to be 0 }
      end

      context "when comparing to an uncomparable value" do
        let(:other) { ["string", nil, num(1i)].sample }

        it { is_expected.to be nil }
      end
    end

    context "with a complex number" do
      let(:compared_number) { num(1.8, 1ri / 2) }
      let(:other) { [num(1, 0.8, 0.5i), Complex(9r / 5, 0.5), 1, composite_number] }

      it { is_expected.to be nil }
    end

    context "with a composite number" do
      let(:compared_number) { composite_number }
      let(:other) { [num(1, 0.8, 0.5i), Complex(9r / 5, 0.5), 1, real_number] }

      it { is_expected.to be nil }
    end
  end
end
