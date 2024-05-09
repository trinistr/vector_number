# frozen_string_literal: true

RSpec.describe VectorNumber do
  it "has a version number" do
    expect(VectorNumber::VERSION).not_to be_nil
  end

  describe ".[]" do
    it "creates a new Vector" do
      expect(described_class[1, 2, 3]).to be_a VectorNumber::Vector
    end
  end
end
