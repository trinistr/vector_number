# frozen_string_literal: true

RSpec.describe VectorNumber do
  let(:zero_number) { num(Complex(0, 0), 0.0, 1, -1) }
  let(:real_number) { num(-1.5r) }
  let(:composite_number) { num("y", :a, 5) }
  let(:f_number) { num("f") }

  let(:vector_u) { [zero_number, real_number, composite_number, f_number].sample }
  let(:vector_v) { [zero_number, real_number, composite_number, f_number].sample }
  let(:vector_w) { [zero_number, real_number, composite_number, f_number].sample }
  let(:scalar_a) { rand(BigDecimal(-10)..BigDecimal(10)) * rand(BigDecimal(0.1)..BigDecimal(100)) }
  let(:scalar_b) { rand(BigDecimal(-10)..BigDecimal(10)) * rand(BigDecimal(0.1)..BigDecimal(100)) }

  # These tests "prove" that we are actually working with a vector space.
  # @see https://en.wikipedia.org/wiki/Vector_space#Definition_and_basic_properties
  describe "vector space axioms" do
    specify "associativity of vector addition" do
      expect(vector_u + (vector_v + vector_w)).to eq (vector_u + vector_v) + vector_w
    end

    specify "commutativity of vector addition" do
      expect(vector_u + vector_v).to eq vector_v + vector_u
    end

    specify "identity element of vector addition" do
      expect(vector_u + num(0)).to eq vector_u
    end

    specify "inverse elements of vector addition" do
      expect(vector_u + (-vector_u)).to eq num(0) # rubocop:disable Style/RedundantParentheses
      expect(vector_u - vector_u).to eq num(0)
    end

    specify "compatibility of scalar multiplication with field multiplication" do
      expect(scalar_a * (scalar_b * vector_u)).to eq (scalar_a * scalar_b) * vector_u
    end

    specify "identity element of scalar multiplication" do
      expect(1 * vector_v).to eq vector_v
    end

    specify "distributivity of scalar multiplication with respect to vector addition" do
      expect(scalar_b * (vector_u + vector_w)).to eq (scalar_b * vector_u) + (scalar_b * vector_w)
    end

    specify "distributivity of scalar multiplication with respect to field addition" do
      expect((scalar_a + scalar_b) * vector_v).to eq (scalar_a * vector_v) + (scalar_b * vector_v)
    end
  end

  describe "consequences of axioms" do
    specify "zero scalar element of scalar multiplication" do
      expect(0 * vector_u).to eq num(0)
    end

    specify "zero vector element of scalar multiplication" do
      expect(scalar_a * num(0)).to eq num(0)
    end

    specify "multiplcation by inverse of of multiplication identity" do
      expect(-1 * vector_u).to eq(-vector_u)
    end
  end
end
