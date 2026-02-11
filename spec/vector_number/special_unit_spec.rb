# frozen_string_literal: true

RSpec.describe VectorNumber::SpecialUnit do
  describe ".new" do
    it "creates a new special unit" do
      unit = described_class.new(1, "m")
      expect(unit).to be_a described_class
    end
  end

  describe "#to_s" do
    it "returns predefined string" do
      expect(described_class.new(1, "m").to_s).to eq "m"
      expect(described_class.new(10, "qwe").to_s).to eq "qwe"
    end
  end

  describe "#inspect" do
    it "returns string representation for debugging, including identifier" do
      expect(described_class.new(13, "asd").inspect).to eq "unit/13"
      expect(described_class.new(:i, "asd").inspect).to eq "unit/i"
    end
  end

  describe "#pretty_print", :pretty_print do
    it "prints the same text as #inspect" do
      unit = described_class.new("AA!#{rand(1000).to_s(36)}", "m")
      expect(unit.pretty_print_inspect).to eq unit.inspect
    end
  end

  describe "#==" do
    it "returns true for the same unit" do
      unit = described_class.new(1, "m")
      expect(unit).to eq unit # rubocop:disable RSpec/IdenticalEqualityAssertion
    end

    it "returns false for different units" do
      unit_1 = described_class.new(1, "m")
      unit_2 = described_class.new(2, "m")
      expect(unit_1).not_to eq unit_2
    end

    it "returns false for different object with same attributes" do
      unit_1 = described_class.new(1, "m")
      unit_2 = described_class.new(1, "m")
      expect(unit_1).not_to eq unit_2
    end
  end
end
