# frozen_string_literal: true

RSpec.describe VectorNumber do
  let(:real_number) { num(567/120r) }
  let(:composite_number) { num("y", :a, 5) }

  describe "#==" do
    subject { (rand > 0.5) ? compared_number == other : other == compared_number }

    context "when comparing to itself" do
      let(:compared_number) { num([13, 8.7.i, "oui", "ya", Object.new].sample(3)) }
      let(:other) { compared_number }

      it { is_expected.to be true }
    end

    context "when comparing to a random object" do
      let(:compared_number) { num([13, 8.7.i, "oui", "ya", Object.new].sample(3)) }
      let(:other) { Object.new }

      it { is_expected.to be false }
    end

    context "when comparing to a non-numeric object that is superficially similar" do
      let(:compared_number) { num([13, 8.7, "oui", "ya"]) }
      let(:other) { [13, 8.7, "oui", "ya"] }

      it { is_expected.to be false }
    end

    context "with a simple number" do
      let(:compared_number) { real_number }

      context "when comparing to an equal value of the same class" do
        let(:other) { num(567/120r) }

        it { is_expected.to be true }
      end

      context "when comparing to an equal value of the same class with non-eql? coefficients" do
        let(:other) { num(4.725) }

        it { is_expected.to be true }
      end

      context "when comparing to an equal value of a different class" do
        let(:other) { 567.fdiv(120) }

        it { is_expected.to be true }
      end

      context "when comparing to BigDecimal of an equal value", :bigdecimal do
        let(:other) { BigDecimal(567) / 120 }

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

      context "when comparing to a different value of a numeric class" do
        let(:other) { [5, -13.2, 17r].sample }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [[], "string", nil].sample }

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

      context "when some value is equal but non-eql?" do
        let(:other) { num("y", :a, 5.0) }

        it { is_expected.to be true }
      end

      context "when comparing to a different value of a numeric class" do
        let(:other) { [5, -13.2, 17r].sample }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [[], "string", nil].sample }

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

      context "when comparing to an equal value of the same class with non-eql? coefficients" do
        let(:other) { num(4.725) }

        it { is_expected.to be false }
      end

      context "when comparing to an equal value of a different class" do
        let(:other) { 567/120r }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of the same class" do
        let(:other) { composite_number }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a numeric class" do
        let(:other) { [5, -13.2, 17r].sample }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [[], "string", nil].sample }

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

      context "when some values are not the same" do
        let(:other) { num("y", "a", 5) }

        it { is_expected.to be false }
      end

      context "when some value is equal but non-eql?" do
        let(:other) { num("y", :a, 5.0) }

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

      context "when comparing to a different value of a numeric class" do
        let(:other) { [5, -13.2, 17r].sample }

        it { is_expected.to be false }
      end

      context "when comparing to a different value of a different class" do
        let(:other) { [[], "string", nil].sample }

        it { is_expected.to be false }
      end
    end
  end

  describe "#hash" do
    subject(:hash) { composite_number.hash }

    it "is equal for equal vectors" do
      expect(hash).to eq num(2, "y", :a, 3).hash
    end

    it "is usually not equal for different vectors" do
      expect(hash).not_to eq num(5, "y", :b).hash
    end

    it "is usually not equal for different classes" do
      expect(hash).not_to eq({ VectorNumber::R => 5, "y" => 1, :a => 1 }.hash)
    end
  end

  describe "#<=>" do
    subject { forward_comparison ? compared_number <=> other : other <=> compared_number }

    let(:forward_comparison) { true }

    shared_examples "comparisons" do |forward, reverse|
      context "with forward comparison" do
        it { is_expected.to be forward }
      end

      context "with reverse comparison" do
        let(:forward_comparison) { false }

        it { is_expected.to be reverse }
      end
    end

    context "with a simple number" do
      let(:compared_number) { real_number }

      context "when comparing to a larger value of the same class" do
        let(:other) { num(567) }

        include_examples "comparisons", -1, 1
      end

      context "when comparing to a smaller value of a different class" do
        let(:other) { 567.fdiv(1200) }

        include_examples "comparisons", 1, -1
      end

      context "when comparing to an equal value" do
        let(:other) { [num(567r / 120), 567.0 / 120].sample }

        include_examples "comparisons", 0, 0
      end

      context "when comparing to an imaginary value" do
        let(:other) { 2i }

        include_examples "comparisons", nil, nil
      end

      context "when comparing to a composite number" do
        let(:other) { num("eg", :g) }

        include_examples "comparisons", nil, nil
      end

      context "when comparing to an uncomparable value" do
        let(:other) { ["string", nil, Object.new].sample }

        include_examples "comparisons", nil, nil
      end
    end

    context "with a complex number" do
      let(:compared_number) { num(1.8, 1ri / 2) }
      let(:other) { [num(1, 0.8, 0.5i), Complex(9r / 5, 0.5), 1, composite_number].sample }

      include_examples "comparisons", nil, nil
    end

    context "with a composite number" do
      let(:compared_number) { composite_number }
      let(:other) { [num(1, 0.8, 0.5i), Complex(9r / 5, 0.5), 1, real_number].sample }

      include_examples "comparisons", nil, nil
    end
  end
end
