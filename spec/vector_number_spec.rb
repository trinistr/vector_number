# frozen_string_literal: true

RSpec.describe VectorNumber, :aggregate_failures do
  it "has a version number" do
    expect(VectorNumber::VERSION).not_to be_nil
  end

  describe ".[]" do
    subject(:number) { described_class[1, 4, "a"] }

    it "creates a new VectorNumber" do
      expect(number).to be_a described_class
      expect(number.to_a).to eq [[1, 5], ["a", 1]]
    end
  end
end
