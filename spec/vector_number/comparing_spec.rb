# frozen_string_literal: true

RSpec.describe VectorNumber::Comparing, :aggregate_failures do
  let(:real_number) { num(567/123r) }
  let(:composite_number) { num("y", :a, 5) }

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
        let(:other) { num(567/123r) }

        it { is_expected.to be true }
      end

      context "when comparing to an equal value of a different class" do
        let(:other) { 567/123r }

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
    end
  end
end
