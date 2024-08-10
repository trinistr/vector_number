# frozen_string_literal: true

require "bigdecimal"

RSpec.describe VectorNumber::Comparing do
  let(:real_number) { num(567/120r) }
  let(:composite_number) { num("y", :a, 5) }

  describe "#==" do
    subject { compared_number == other }

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
    subject { compared_number.eql?(other) }

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

  describe "#<=>" do
    subject { compared_number <=> other }

    context "with a simple number" do
      let(:compared_number) { real_number }

      context "when comparing to a larger value of the same class" do
        let(:other) { num(567) }

        it { is_expected.to be(-1) }
      end

      context "when comparing to a smaller value of a different class" do
        let(:other) { BigDecimal("567") / 1200 }

        it { is_expected.to be 1 }
      end

      context "when comparing to an equal value" do
        let(:other) { [num(567r / 120), 567.0 / 120].sample }

        it { is_expected.to be 0 }
      end

      context "when comparing to an uncomparable value" do
        let(:other) { ["string", nil, num(1i)].sample }

        it { is_expected.to be_nil }
      end
    end

    context "with a complex number" do
      let(:compared_number) { num(1.8, 1ri / 2) }
      let(:other) { [num(1, 0.8, 0.5i), Complex(9r / 5, 0.5), 1, composite_number] }

      it { is_expected.to be_nil }
    end

    context "with a composite number" do
      let(:compared_number) { composite_number }
      let(:other) { [num(1, 0.8, 0.5i), Complex(9r / 5, 0.5), 1, real_number] }

      it { is_expected.to be_nil }
    end
  end
end
