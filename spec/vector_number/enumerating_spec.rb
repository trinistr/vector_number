# frozen_string_literal: true

RSpec.describe VectorNumber::Enumerating, :aggregate_failures do
  let(:zero_number) { num(Complex(0, 0), 0.0, 1, -1) }
  let(:real_number) { num(1.5r) }
  let(:composite_number) { num("y", :a, 5) }

  it "includes Enumerable" do
    expect(described_class).to be < Enumerable
  end

  describe "#each" do
    context "when called without block" do
      subject(:enum) { number.each }

      shared_examples "returns Enumerator" do |for_number:, size:|
        let(:number) { public_send(for_number) }

        it "returns Enumerator with expected size" do
          expect(enum).to be_a Enumerator
          expect(enum.size).to be size
        end
      end

      context "with zero" do
        include_examples "returns Enumerator", for_number: :zero_number, size: 0
      end

      context "with simple number" do
        include_examples "returns Enumerator", for_number: :real_number, size: 1
      end

      context "with composite number" do
        include_examples "returns Enumerator", for_number: :composite_number, size: 3
      end
    end

    context "when called with block" do
      subject(:each_call) { ->(b) { number.each(&b) } }

      shared_examples "yields values" do |for_number:, values:|
        let(:number) { public_send(for_number) }

        it "yields each unit and coefficient pair in arbitrary order" do
          expect(&each_call).to yield_successive_args(*values)
        end
      end

      context "with zero" do
        include_examples "yields values", for_number: :zero_number, values: []
      end

      context "with simple number" do
        include_examples "yields values", for_number: :real_number, values: [[1, 1.5r]]
      end

      context "with composite number" do
        include_examples "yields values", for_number: :composite_number, values: [["y", 1], [:a, 1], [1, 5]]
      end
    end
  end

  describe "#each_pair" do
    it "is an alias of #each" do
      expect(described_class.instance_method(:each_pair).original_name).to be :each
    end
  end

  describe "#units" do
    subject(:units) { number.units }

    shared_examples "returns units" do |for_number:, values:|
      let(:number) { public_send(for_number) }

      it "returns array of number's units in arbitrary order" do
        expect(units).to match_array values
      end
    end

    context "with zero" do
      include_examples "returns units", for_number: :zero_number, values: []
    end

    context "with simple number" do
      include_examples "returns units", for_number: :real_number, values: [1]
    end

    context "with composite number" do
      include_examples "returns units", for_number: :composite_number, values: [1, "y", :a]
    end
  end

  describe "#keys" do
    it "is an alias of #units" do
      expect(described_class.instance_method(:keys).original_name).to be :units
    end
  end

  describe "#coefficients" do
    subject(:coefficients) { number.coefficients }

    shared_examples "returns coefficients" do |for_number:, values:|
      let(:number) { public_send(for_number) }

      it "returns array of number's coefficients in arbitrary order" do
        expect(coefficients).to match_array values
      end
    end

    context "with zero" do
      include_examples "returns coefficients", for_number: :zero_number, values: []
    end

    context "with simple number" do
      include_examples "returns coefficients", for_number: :real_number, values: [1.5r]
    end

    context "with composite number" do
      include_examples "returns coefficients", for_number: :composite_number, values: [5, 1, 1]
    end
  end

  describe "#values" do
    it "is an alias of #coefficients" do
      expect(described_class.instance_method(:values).original_name).to be :coefficients
    end
  end

  describe "#to_h" do
    subject(:hash) { number.to_h }

    let(:number) { composite_number }

    it "returns plain vector representation without calling #each" do
      # Can't actually test for not calling #each, as objects are frozen and can't be mocked.
      expect(hash).to eq(1 => 5, "y" => 1, :a => 1)
    end
  end
end
