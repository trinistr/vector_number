# frozen_string_literal: true

require "vector_number/numeric_refinements"

RSpec.describe VectorNumber::NumericRefinements do
  before(:context) do # rubocop:disable RSpec/BeforeAfterAll
    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.1.0")
      skip "Numeric refinements are not available"
    end
  end

  describe Complex, "#<=>" do
    let(:number) { rand(Complex(-100, 0)..Complex(0, 0)) }

    context "with refinements" do
      using VectorNumber::NumericRefinements

      subject(:comparison) { number <=> other }

      context "when comparing to a comparable core number" do
        let(:other) { [15, 23.23, 0.3r, Complex(37r, 0)].sample }

        it "gives a result" do
          expect(comparison).to eq(-1)
        end
      end

      context "when comparing to a BigDecimal", :bigdecimal do
        let(:other) { BigDecimal(5) }

        it "gives a result" do
          expect(comparison).to eq(-1)
        end
      end

      context "when comparing to a VectorNumber" do
        let(:other) { num(1) }

        it "gives a result" do
          expect(comparison).to eq(-1)
        end
      end

      context "when comparing to an uncomparable object" do
        let(:other) { [Object.new, num(2i)] }

        it "returns nil" do
          expect(comparison).to be nil
        end
      end
    end
  end

  describe Kernel, "#BigDecimal", :bigdecimal do
    using VectorNumber::NumericRefinements

    # NB: Method must be called after `using` refinements for them to work, even in a block.
    let(:number) { rand(-300.0..3000.0).round(3) }

    context "when converting a vector number" do
      subject(:conversion) { BigDecimal(num(number)) }

      context "without second argument" do
        it "returns an equivalent BigDecimal" do
          expect(conversion).to be_a(BigDecimal).and eq number
        end
      end

      context "with second argument" do
        subject(:conversion) { BigDecimal(num(number), 2) }

        let(:number) { rand(10.0...20.0) }

        it "returns an equivalent BigDecimal after rounding" do
          expect(conversion).to be_a(BigDecimal).and eq number.round
        end
      end
    end

    context "when converting a String" do
      subject(:conversion) { BigDecimal(number.to_s) }

      context "without second argument" do
        it "returns an equivalent BigDecimal" do
          expect(conversion).to be_a(BigDecimal).and eq number
        end
      end

      # Second argument is ignored for conversion from String.
      context "with second argument" do
        subject(:conversion) { BigDecimal(number.to_s, 2) }

        it "does not perform rounding" do
          expect(conversion).to be_a(BigDecimal).and eq number
        end
      end
    end

    context "when converting a Float" do
      subject(:conversion) { BigDecimal(number) }

      context "without second argument" do
        # https://github.com/ruby/bigdecimal/blob/master/CHANGES.md#323
        if BigDecimal::VERSION < "3.2.3"
          it "raises ArgumentError" do
            expect { conversion }.to raise_error ArgumentError
          end
        else
          it "returns an equivalent BigDecimal" do
            expect(conversion).to be_a(BigDecimal).and eq number
          end
        end
      end

      context "with second argument" do
        subject(:conversion) { BigDecimal(number, 2) }

        let(:number) { rand(100.0...200.0) }

        it "returns an equivalent BigDecimal after rounding" do
          expect(conversion).to be_a(BigDecimal).and eq number.round(-1)
        end
      end
    end
  end
end
