# frozen_string_literal: true

RSpec.describe VectorNumber, :aggregate_failures do
  it "has a proper version number" do
    expect(described_class::VERSION).not_to be_nil
    expect { Gem::Version.new(described_class::VERSION) }.not_to raise_error
  end

  describe ".[]" do
    subject(:number) { described_class[1, 4, "a"] }

    it "creates a new VectorNumber" do
      expect(number).to be_a described_class
      expect(number.to_a).to contain_exactly [0.i, 5], ["a", 1]
    end
  end
end
