# frozen_string_literal: true

require "vector_number/numeric_refinements"

RSpec.describe VectorNumber::NumericRefinements do
  shared_examples "<=>" do
    describe "#<=>" do
      context "without refinements" do
        subject(:comparison) { number <=> other }

        context "when comparing to a comparable core number" do
          let(:other) { [15, -23.23, 0.3r, BigDecimal("5"), Complex(37r, 0)].sample }

          it "gives a result" do
            expect(comparison).to be_an Integer
          end
        end

        context "when comparing to a VectorNumber" do
          let(:other) { num(1) }

          it "returns nil" do
            expect(comparison).to be nil
          end
        end

        context "when comparing to an uncomparable object" do
          let(:other) { Object.new }

          it "returns nil" do
            expect(comparison).to be nil
          end
        end
      end

      context "with refinements" do
        using described_class

        subject(:comparison) { number <=> other }

        context "when comparing to a comparable core number" do
          let(:other) { [15, -23.23, 0.3r, BigDecimal("5"), Complex(37r, 0)].sample }

          it "gives a result" do
            expect(comparison).to be_an Integer
          end
        end

        context "when comparing to a VectorNumber" do
          let(:other) { num(1) }

          it "gives a result" do
            expect(comparison).to be_an Integer
          end
        end

        context "when comparing to an uncomparable object" do
          let(:other) { Object.new }

          it "returns nil" do
            expect(comparison).to be nil
          end
        end
      end
    end
  end

  describe "Complex" do
    let(:number) { rand(Complex(-100, 0)..Complex(100, 0)) }

    include_examples "<=>"
  end
end
