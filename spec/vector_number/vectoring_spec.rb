# frozen_string_literal: true

RSpec.describe VectorNumber do
  let(:zero_number) { num }
  let(:real_number) { num(999.15) }
  let(:complex_number) { num(Complex(0.12, -13.5)) }
  let(:composite_number) { num("y", :a, 5, Complex(3, 5), 1.3i) }

  describe "#abs", :aggregate_failures do
    it "returns magnitude of the vector as a Float" do
      expect(zero_number.abs).to be 0.0
      expect(real_number.abs).to be 999.15
      # These are exact values. Should be crossplatform too.
      expect(complex_number.abs).to be 13.50053332279877
      expect(composite_number.abs).to be 10.280564186852782
    end
  end

  include_examples "has an alias", :magnitude, :abs

  describe "#abs2", :aggregate_failures do
    it "returns square of the magnitude as a Float" do
      expect(zero_number.abs2).to be 0
      expect(real_number.abs2).to be 999.15**2
      expect(complex_number.abs2).to be (0.12**2) + (13.5**2)
      expect(composite_number.abs2).to be 1 + 1 + (8**2) + (6.3**2)
    end
  end
end
