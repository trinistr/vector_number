# frozen_string_literal: true

RSpec.describe VectorNumber, :aggregate_failures do
  let(:zero_number) { num }
  let(:real_number) { num(999.15) }
  let(:complex_number) { num(Complex(0.12, -13.5)) }
  let(:composite_number) { num("y", :a, 5, Complex(3, 5), 1.3i) }

  describe "#magnitude" do
    it "returns magnitude of the vector as a Float" do
      expect(zero_number.magnitude).to be 0.0
      expect(real_number.magnitude).to be 999.15
      # These are exact values. Should be crossplatform too.
      expect(complex_number.magnitude).to be 13.50053332279877
      expect(composite_number.magnitude).to be 10.280564186852782
    end
  end

  include_examples "has an alias", :abs, :magnitude

  describe "#abs2" do
    it "returns square of the magnitude as a Float" do
      expect(zero_number.abs2).to be 0
      expect(real_number.abs2).to be 999.15**2
      expect(complex_number.abs2).to be (0.12**2) + (13.5**2)
      expect(composite_number.abs2).to be 1 + 1 + (8**2) + (6.3**2)
    end
  end

  describe "#p_norm" do
    context "with p = 1" do
      it "returns taxicab norm of the vector as a Float" do
        expect(zero_number.p_norm(1)).to be 0.0
        expect(real_number.p_norm(1)).to be 999.15
        expect(complex_number.p_norm(1)).to be 13.62
        expect(composite_number.p_norm(1)).to be 16.3
      end
    end

    context "with p = 2" do
      it "returns euclidean norm of the vector as a Float" do
        expect(zero_number.p_norm(2)).to be 0.0
        expect(real_number.p_norm(2)).to be 999.15
        expect(complex_number.p_norm(2)).to be 13.50053332279877
        expect(composite_number.p_norm(2)).to be 10.280564186852782
      end

      it "is equal to #abs" do
        expect(zero_number.abs).to be zero_number.p_norm(2)
        expect(real_number.abs).to be real_number.p_norm(2)
        expect(complex_number.abs).to be complex_number.p_norm(2)
        expect(composite_number.abs).to be composite_number.p_norm(2)
      end
    end

    context "with p = 0.5" do
      it "returns 0.5-norm of the vector as a Float" do
        expect(zero_number.p_norm(0.5)).to be 0.0
        expect(real_number.p_norm(0.5)).to be (999.15**0.5)**2
        expect(complex_number.p_norm(0.5)).to be 16.16558441227157
        expect(composite_number.p_norm(0.5)).to be 53.852220296832755
      end
    end
  end

  describe "#maximum_norm" do
    it "returns maximum norm of the vector" do
      expect(zero_number.maximum_norm).to be 0
      expect(real_number.maximum_norm).to be 999.15
      expect(complex_number.maximum_norm).to be 13.5
      expect(composite_number.maximum_norm).to be 8
    end
  end

  include_examples "has an alias", :infinity_norm, :maximum_norm

  describe "#subspace_basis" do
    it "returns array of unit vectors formin a subspace basis based on the vector" do
      expect(zero_number.subspace_basis).to eq []
      expect(real_number.subspace_basis).to eq [num(1)]
      expect(complex_number.subspace_basis).to eq [num(1), num(1i)]
      expect(composite_number.subspace_basis).to eq [num("y"), num(:a), num(1), num(1i)]
    end
  end

  describe "#uniform_vector" do
    it "returns a vector with same dimensions but all components equal to 1" do
      expect(zero_number.uniform_vector).to eq num(0)
      expect(real_number.uniform_vector).to eq num(1)
      expect(complex_number.uniform_vector).to eq num(1, 1i)
      expect(composite_number.uniform_vector).to eq num(1, 1i, "y", :a)
    end
  end

  describe "#unit_vector" do
    it "returns a vector with same dimensions but normalized to unit length" do
      expect(real_number.unit_vector).to eq num(1)
      expect(complex_number.unit_vector).to eq complex_number / complex_number.magnitude
      expect(composite_number.unit_vector).to eq composite_number / composite_number.magnitude
    end

    it "raises ZeroDivisionError for zero vector" do
      expect { zero_number.unit_vector }.to raise_error(ZeroDivisionError)
    end
  end

  describe "#dot_product" do
    it "calculates the dot product of two vectors" do
      expect(real_number.dot_product(num(2))).to eq 1998.3
      expect(complex_number.dot_product(num(1i))).to eq(-13.5)
      expect(composite_number.dot_product(num(:a, 1, 1i, "y"))).to eq 16.3
    end

    it "returns 0 if either of the vectors is zero" do
      expect(zero_number.dot_product(num(1))).to eq 0
      expect(num(1).dot_product(zero_number)).to eq 0
      expect(zero_number.dot_product(num(0))).to eq 0
    end

    it "returns 0 if vectors don't have dimensions in common" do
      expect(real_number.dot_product(num(:a))).to eq 0
      expect(complex_number.dot_product(num("y"))).to eq 0
      expect(composite_number.dot_product(num(:b, "f"))).to eq 0
    end

    it "returns 0 if vectors are orthogonal" do
      expect(num(1, 1i).dot_product(num(1, -1i))).to eq 0
      expect(num(1, "a").dot_product(num("a", -1))).to eq 0
    end

    it "is equal to #abs2 if other vector is the same vector" do
      expect(real_number.dot_product(real_number)).to eq real_number.abs2
      expect(complex_number.dot_product(complex_number)).to eq complex_number.abs2
      expect(composite_number.dot_product(composite_number)).to eq composite_number.abs2
    end

    it "is equal to #abs2 if other is an equal vector" do
      expect(real_number.dot_product(num(999.15))).to eq real_number.abs2
      expect(complex_number.dot_product(num(0.12, -13.5i))).to eq complex_number.abs2
      expect(composite_number.dot_product(num("y", :a, 8, 6.3i))).to eq composite_number.abs2
    end

    it "automatically promotes other to a VectorNumber" do
      expect(real_number.dot_product(2)).to eq real_number.dot_product(num(2))
      expect(complex_number.dot_product(1i)).to eq complex_number.dot_product(num(1i))
      expect(composite_number.dot_product(:a)).to eq composite_number.dot_product(num(:a))
    end
  end

  include_examples "has an alias", :inner_product, :dot_product
  include_examples "has an alias", :scalar_product, :dot_product

  describe "#angle" do
    it "returns angle between two vectors in radians" do
      expect(real_number.angle(num(2))).to eq 0
      expect(complex_number.angle(num(-0.12, 13.5i))).to eq Math::PI
      expect(composite_number.angle(composite_number.uniform_vector)).to eq 0.6554757214091224
    end

    it "always returns 0 if other is the same vector" do
      expect(real_number.angle(real_number)).to be 0.0
      expect(complex_number.angle(complex_number)).to be 0.0
      expect(composite_number.angle(composite_number)).to be 0.0
    end

    it "returns 0 if other is an equal vector" do
      expect(real_number.angle(num(999.15))).to be 0.0
      expect(complex_number.angle(num(0.12, -13.5i))).to be 0.0
      expect(composite_number.angle(num("y", :a, 8, 6.3i))).to be 0.0
    end

    it "returns π/2 if vectors are orthogonal" do
      expect(num(1, 1i).angle(num(1, -1i))).to be Math::PI / 2.0
      expect(num(1, "a").angle(num("a", -1))).to be Math::PI / 2.0
    end

    it "returns ≈0 if vectors are codirectional" do
      expect(num(1, 1i).angle(num(2, 2i))).to be_within(1e-7).of(0.0)
      expect(num(1, "a").angle(num("a", 1) * 0.34)).to be_within(1e-7).of(0.0)
      expect(composite_number.angle(composite_number.unit_vector)).to be_within(1e-7).of(0.0)
    end

    it "returns ≈π if vectors are opposite" do
      expect(num(1, 1i).angle(num(-2, -2i))).to be_within(1e-7).of(Math::PI)
      expect(num(1, "a").angle(num("a", 1) * -0.34)).to be_within(1e-7).of(Math::PI)
      expect(composite_number.angle(composite_number.unit_vector * -1)).to be_within(1e-7).of(Math::PI)
    end

    it "raises ZeroDivisionError if either vector is a zero vector" do
      expect { zero_number.angle(num(1)) }.to raise_error(ZeroDivisionError)
      expect { num(1).angle(zero_number) }.to raise_error(ZeroDivisionError)
    end

    it "automatically promotes other to a VectorNumber" do
      expect(real_number.angle(2)).to eq real_number.angle(num(2))
      expect(complex_number.angle(1i)).to eq complex_number.angle(num(1i))
      expect(composite_number.angle(:a)).to eq composite_number.angle(num(:a))
    end
  end

  describe "#vector_projection" do
    it "returns the vector projection of self onto other" do
      expect(real_number.vector_projection(complex_number))
        .to eq num(0.07893894803373559, -8.880631653795255i)
      expect(complex_number.vector_projection(num(1))).to eq num(0.12)
      expect(complex_number.vector_projection(num(1i))).to eq num(-13.5i)
      expect(composite_number.vector_projection(real_number)).to eq num(8)
      expect(composite_number.vector_projection(num("y", :a, 1, 1i)))
        .to eq num(1, 1i, "y", :a) * 4.075
    end

    it "returns zero vector if vectors don't have dimensions in common" do
      expect(real_number.vector_projection(num(:a))).to eq num(0)
      expect(complex_number.vector_projection(num("y"))).to eq num(0)
      expect(composite_number.vector_projection(num(:b, "f"))).to eq num(0)
    end

    it "returns zero vector if vectors are orthogonal" do
      expect(num(1, 1i).vector_projection(num(1, -1i))).to eq num(0)
      expect(num(1, "a").vector_projection(num("a", -1))).to eq num(0)
    end

    it "returns zero vector if self is a zero vector" do
      expect(zero_number.vector_projection(num(1))).to eq num(0)
    end

    it "raises ZeroDivisionError if other is a zero vector" do
      expect { real_number.vector_projection(num(0)) }.to raise_error(ZeroDivisionError)
    end

    it "automatically promotes other to a VectorNumber" do
      expect(real_number.vector_projection(2)).to eq real_number.vector_projection(num(2))
      expect(complex_number.vector_projection(1i)).to eq complex_number.vector_projection(num(1i))
      expect(composite_number.vector_projection(:a))
        .to eq composite_number.vector_projection(num(:a))
    end
  end

  describe "#scalar_projection" do
    it "returns the scalar projection of self onto other" do
      expect(real_number.scalar_projection(complex_number)).to eq 8.8809824866344
      expect(complex_number.scalar_projection(num(1))).to eq 0.12
      expect(complex_number.scalar_projection(num(1i))).to eq(-13.5)
      expect(composite_number.scalar_projection(real_number)).to eq 8.0
      expect(composite_number.scalar_projection(num("y", :a, 1, 1i))).to eq 8.15
    end

    it "is absolutely equal to #magnitude of #vector_projection" do
      expect(complex_number.scalar_projection(num(1i)))
        .to eq(-complex_number.vector_projection(num(1i)).magnitude)
      expect(composite_number.scalar_projection(real_number))
        .to eq composite_number.vector_projection(real_number).magnitude
      expect(composite_number.scalar_projection(num("y", :a, 1, 1i)))
        .to eq composite_number.vector_projection(num("y", :a, 1, 1i)).magnitude
    end

    it "returns zero if vectors don't have dimensions in common" do
      expect(real_number.scalar_projection(num(:a))).to eq 0.0
      expect(complex_number.scalar_projection(num("y"))).to eq 0.0
      expect(composite_number.scalar_projection(num(:b, "f"))).to eq 0.0
    end

    it "returns zero if vectors are orthogonal" do
      expect(num(1, 1i).scalar_projection(num(1, -1i))).to eq 0.0
      expect(num(1, "a").scalar_projection(num("a", -1))).to eq 0.0
    end

    it "returns zero if self is a zero vector" do
      expect(zero_number.scalar_projection(num(1))).to eq 0.0
    end

    it "raises ZeroDivisionError if other is a zero vector" do
      expect { real_number.scalar_projection(num(0)) }.to raise_error(ZeroDivisionError)
    end

    it "automatically promotes other to a VectorNumber" do
      expect(real_number.scalar_projection(2)).to eq real_number.scalar_projection(num(2))
      expect(complex_number.scalar_projection(1i)).to eq complex_number.scalar_projection(num(1i))
      expect(composite_number.scalar_projection(:a))
        .to eq composite_number.scalar_projection(num(:a))
    end
  end

  describe "#vector_rejection" do
    it "returns the vector rejection of self from other" do
      expect(real_number.vector_rejection(complex_number))
        .to eq num(999.0710610519662, 8.880631653795255i)
      expect(complex_number.vector_rejection(1)).to eq num(-13.5i)
      expect(composite_number.vector_rejection(num(:a, 2, "y")))
        .to eq num("y", :a) * -2.0 + 2.0 + 6.3i
    end

    it "is equal to self - vector_projection(other)" do
      expect(real_number.vector_rejection(complex_number))
        .to eq real_number - real_number.vector_projection(complex_number)
      expect(complex_number.vector_rejection(real_number))
        .to eq complex_number - complex_number.vector_projection(real_number)
      expect(composite_number.vector_rejection(num(:a, 1, 1i, "y")))
        .to eq composite_number - composite_number.vector_projection(num(:a, 1, 1i, "y"))
    end

    it "returns self if vectors don't have dimensions in common" do
      expect(real_number.vector_rejection(num(:a))).to eq real_number
      expect(complex_number.vector_rejection(num("y"))).to eq complex_number
      expect(composite_number.vector_rejection(num(:b, "f"))).to eq composite_number
    end

    it "returns self if vectors are orthogonal" do
      expect(num(1, 1i).vector_rejection(num(1, -1i))).to eq num(1, 1i)
      expect(num(1, "a").vector_rejection(num("a", -1))).to eq num(1, "a")
    end

    it "returns zero vector if other is the same vector" do
      expect(num(1, 1i).vector_rejection(num(1, 1i))).to eq num(0)
      expect(num(1, "a").vector_rejection(num(1, "a"))).to eq num(0)
      expect(composite_number.vector_rejection(composite_number)).to eq num(0)
    end

    it "returns zero vector if self is a zero vector" do
      expect(zero_number.vector_rejection(num(1))).to eq num(0)
    end

    it "raises ZeroDivisionError if other is a zero vector" do
      expect { real_number.vector_rejection(num(0)) }.to raise_error(ZeroDivisionError)
    end

    it "automatically promotes other to a VectorNumber" do
      expect(num(1, 1i).vector_rejection(1)).to eq num(1, 1i).vector_rejection(num(1))
      expect(num(1, "a").vector_rejection(1i)).to eq num(1, "a").vector_rejection(num(1i))
      expect(composite_number.vector_rejection(:a)).to eq composite_number.vector_rejection(num(:a))
    end
  end

  describe "#scalar_rejection" do
    it "returns the scalar rejection of self from other" do
      expect(real_number.scalar_rejection(complex_number)).to eq 999.1105297463699
      expect(complex_number.scalar_rejection(real_number)).to eq 13.5
      expect(composite_number.scalar_rejection(num(:a, 2, "y"))).to eq 7.189575787207476
    end

    it "is equal to #magnitude of #vector_rejection" do
      expect(real_number.scalar_rejection(complex_number))
        .to eq real_number.vector_rejection(complex_number).magnitude
      expect(complex_number.scalar_rejection(real_number))
        .to eq complex_number.vector_rejection(real_number).magnitude
      expect(composite_number.scalar_rejection(num(:a, 1, 1i, "y")))
        .to eq composite_number.vector_rejection(num(:a, 1, 1i, "y")).magnitude
    end

    it "returns zero if other is the same vector" do
      expect(num(1, 1i).scalar_rejection(num(1, 1i))).to eq 0.0
      expect(num(1, "a").scalar_rejection(num(1, "a"))).to eq 0.0
      expect(composite_number.scalar_rejection(composite_number)).to eq 0.0
    end

    it "returns zero if self is a zero vector" do
      expect(zero_number.scalar_rejection(num(1))).to eq 0.0
    end

    it "raises ZeroDivisionError if other is a zero vector" do
      expect { real_number.scalar_rejection(num(0)) }.to raise_error(ZeroDivisionError)
    end

    it "automatically promotes other to a VectorNumber" do
      expect(num(1, 1i).scalar_rejection(1)).to eq num(1, 1i).scalar_rejection(num(1))
      expect(num(1, "a").scalar_rejection(1i)).to eq num(1, "a").scalar_rejection(num(1i))
      expect(composite_number.scalar_rejection(:a)).to eq composite_number.scalar_rejection(num(:a))
    end
  end
end
