# frozen_string_literal: true

RSpec.describe VectorNumber do
  let(:zero_number) { num(Complex(0, 0), 0.0, 1, -1) }
  let(:real_number) { num(1.5r) }
  let(:composite_number) { num("y", :a, 5) }

  it "includes Enumerable" do
    expect(described_class).to be < Enumerable
  end

  describe "#each" do
    context "when called without block", :aggregate_failures do
      subject(:enum) { number.each }

      shared_examples "returns Enumerator" do |for_number:, size:|
        context "with #{for_number.to_s.tr("_", " ")}" do
          let(:number) { public_send(for_number) }

          it "returns Enumerator with expected size" do
            expect(enum).to be_a Enumerator
            expect(enum.size).to be size
          end
        end
      end

      include_examples "returns Enumerator", for_number: :zero_number, size: 0
      include_examples "returns Enumerator", for_number: :real_number, size: 1
      include_examples "returns Enumerator", for_number: :composite_number, size: 3
    end

    context "when called with block" do
      subject(:each_call) { ->(b) { number.each(&b) } }

      shared_examples "yields values" do |for_number:, values:|
        context "with #{for_number.to_s.tr("_", " ")}" do
          let(:number) { public_send(for_number) }

          it "yields each unit and coefficient pair in arbitrary order" do
            expect(&each_call).to yield_successive_args(*values)
          end
        end
      end

      include_examples "yields values", for_number: :zero_number, values: []
      include_examples "yields values",
                       for_number: :real_number, values: [[described_class::R, 1.5r]]
      include_examples "yields values",
                       for_number: :composite_number,
                       values: [["y", 1], [:a, 1], [described_class::R, 5]]
    end
  end

  include_examples "has an alias", :each_pair, :each

  describe "#units" do
    subject(:units) { number.units }

    shared_examples "returns units" do |for_number:, values:|
      context "with #{for_number.to_s.tr("_", " ")}" do
        let(:number) { public_send(for_number) }

        it "returns array of number's units in arbitrary order" do
          expect(units).to match_array values
        end
      end
    end

    include_examples "returns units", for_number: :zero_number, values: []
    include_examples "returns units", for_number: :real_number, values: [described_class::R]
    include_examples "returns units",
                     for_number: :composite_number, values: [described_class::R, "y", :a]
  end

  include_examples "has an alias", :keys, :units

  describe "#coefficients" do
    subject(:coefficients) { number.coefficients }

    shared_examples "returns coefficients" do |for_number:, values:|
      context "with #{for_number.to_s.tr("_", " ")}" do
        let(:number) { public_send(for_number) }

        it "returns array of number's coefficients in arbitrary order" do
          expect(coefficients).to match_array values
        end
      end
    end

    include_examples "returns coefficients", for_number: :zero_number, values: []
    include_examples "returns coefficients", for_number: :real_number, values: [1.5r]
    include_examples "returns coefficients", for_number: :composite_number, values: [5, 1, 1]
  end

  include_examples "has an alias", :values, :coefficients

  describe "#coefficients_at" do
    subject(:coefficients) { number.coefficients_at(*units) }

    let(:units) { [:a, VectorNumber::R, "s", :a] }

    shared_examples "returns coefficients" do |for_number:, values:|
      context "with #{for_number.to_s.tr("_", " ")}" do
        let(:number) { public_send(for_number) }

        it "returns array of number's coefficients in arbitrary order" do
          expect(coefficients).to eq values
        end
      end
    end

    include_examples "returns coefficients", for_number: :zero_number, values: [0, 0, 0, 0]
    include_examples "returns coefficients", for_number: :real_number, values: [0, 1.5r, 0, 0]
    include_examples "returns coefficients", for_number: :composite_number, values: [1, 5, 0, 1]

    it "returns empty array when no units are given" do
      expect(zero_number.coefficients_at).to eq []
    end
  end

  include_examples "has an alias", :values_at, :coefficients_at

  describe "#to_h" do
    subject(:hash) { number.to_h(&block) }

    let(:number) { composite_number }
    let(:block) { nil }

    context "without a block" do
      it "returns plain vector representation without calling #each" do
        # Can't actually test for not calling #each, as objects are frozen and can't be mocked.
        expect(hash).to eq(described_class::R => 5, "y" => 1, :a => 1)
      end
    end

    context "with a block" do
      let(:block) { ->(u, v) { [u, described_class.numeric_unit?(u) ? v : v * 0.5] } }

      it "returns transformed plain vector representation" do
        expect(hash).to eq(described_class::R => 5, "y" => 0.5, :a => 0.5)
      end
    end
  end

  describe "#[]" do
    subject(:value) { number[unit] }

    let(:number) { composite_number * 0.75 }

    context "with an existing unit" do
      let(:unit) { "y" }

      it "returns the coefficient" do
        expect(value).to eq 0.75
      end
    end

    context "with a numeric unit" do
      let(:unit) { VectorNumber::R }

      it "returns the numeric coefficient" do
        expect(value).to eq 3.75
      end
    end

    context "with a non-existent unit" do
      let(:unit) { "x" }

      it "returns 0" do
        expect(value).to eq 0
      end
    end
  end

  describe "#assoc" do
    subject(:value) { number.assoc(unit) }

    let(:number) { composite_number * 0.75 }

    context "with an existing unit" do
      let(:unit) { "y" }

      it "returns the unit and coefficient" do
        expect(value).to eq ["y", 0.75]
      end
    end

    context "with a numeric unit" do
      let(:unit) { VectorNumber::R }

      it "returns the numeric unit and coefficient" do
        expect(value).to eq [VectorNumber::R, 3.75]
      end
    end

    context "with a non-existent unit" do
      let(:unit) { "x" }

      it "returns the unit and 0" do
        expect(value).to eq ["x", 0]
      end
    end
  end

  describe "#dig" do
    it "digs to the coefficient" do
      expect(composite_number.dig("y")).to eq 1 # rubocop:disable Style/SingleArgumentDig
    end

    it "returns 0 for non-existent unit" do
      expect(composite_number.dig("x")).to eq 0 # rubocop:disable Style/SingleArgumentDig
    end

    it "works when vector is buried in a different collection" do
      expect([composite_number].dig(0, VectorNumber::R)).to eq 5
    end
  end

  describe "#fetch" do
    context "without default value or block" do
      it "returns coefficient for existing unit" do
        expect(composite_number.fetch("y")).to eq 1
      end

      it "raises KeyError for non-existent unit" do
        expect { composite_number.fetch("x") }.to raise_error KeyError
      end
    end

    context "with default value" do
      it "returns coefficient for existing unit" do
        expect(composite_number.fetch(:a, "AAAA")).to eq 1
      end

      it "returns default value for non-existent unit" do
        expect(composite_number.fetch("x", "AAAA")).to eq "AAAA"
      end
    end

    context "with block" do
      it "returns coefficient for existing unit" do
        expect(composite_number.fetch(VectorNumber::R) { "AAAA#{_1}" }).to eq 5
      end

      it "returns block's value for non-existent unit" do
        expect(composite_number.fetch("x") { "AAAA#{_1}" }).to eq "AAAAx"
      end
    end
  end

  describe "#fetch_coefficients" do
    context "without block" do
      it "returns coefficients for existing units in the specified order" do
        expect(composite_number.fetch_coefficients(VectorNumber::R, "y", "y")).to eq [5, 1, 1]
      end

      it "raises KeyError for non-existent units" do
        expect { composite_number.fetch_coefficients("y", "x") }.to raise_error KeyError
      end
    end

    context "with block" do
      it "returns coefficients for existing units in the specified order" do
        expect(composite_number.fetch_coefficients(VectorNumber::R, "y", "y") { "AAAA#{_1}" })
          .to eq [5, 1, 1]
      end

      it "returns block's value for non-existent units" do
        expect(composite_number.fetch_coefficients("x", "y") { "AAAA#{_1}" }).to eq ["AAAAx", 1]
      end
    end

    it "returns empty array when no units are given" do
      expect(zero_number.fetch_coefficients).to eq []
    end
  end

  include_examples "has an alias", :fetch_values, :fetch_coefficients

  describe "#unit?" do
    subject(:unit?) { number.unit?(unit) }

    let(:number) { composite_number }

    context "with an existing unit" do
      let(:unit) { "y" }

      it { is_expected.to be true }
    end

    context "with a numeric unit" do
      let(:unit) { VectorNumber::R }

      it { is_expected.to be true }
    end

    context "with a non-existent unit" do
      let(:unit) { "x" }

      it { is_expected.to be false }
    end
  end

  include_examples "has an alias", :key?, :unit?
end
