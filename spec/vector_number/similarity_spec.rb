# frozen_string_literal: true

RSpec.describe VectorNumber, :aggregate_failures do
  let(:zero_number) { num }
  let(:real_number) { num(999.15) }
  let(:complex_number) { num(Complex(0.12, -13.5)) }
  let(:composite_number) { num("y", :a, 5, Complex(3, 5), 1.3i) }

  describe "#cosine_similarity" do
    it "returns cosine similarity between two vectors" do
      expect(real_number.cosine_similarity(num(2))).to eq 1.0
      expect(complex_number.cosine_similarity(num(-0.12, 13.5i))).to eq(-1.0)
      expect(composite_number.cosine_similarity(composite_number.uniform_vector))
        .to eq 0.792758048281296
    end

    it "returns 1 if other is the same vector" do
      expect(real_number.cosine_similarity(real_number)).to be 1.0
      expect(complex_number.cosine_similarity(complex_number)).to be 1.0
      expect(composite_number.cosine_similarity(composite_number)).to be 1.0
    end

    it "returns 1 if other is an equal vector" do
      expect(real_number.cosine_similarity(num(999.15))).to be 1.0
      expect(complex_number.cosine_similarity(num(0.12, -13.5i))).to be 1.0
      expect(composite_number.cosine_similarity(num("y", :a, 8, 6.3i))).to be 1.0
    end

    it "returns 0 if vectors are orthogonal" do
      expect(num(1, 1i).cosine_similarity(num(1, -1i))).to be 0.0
      expect(num(1, "a").cosine_similarity(num("a", -1))).to be 0.0
    end

    it "returns ≈0 if vectors are codirectional" do
      expect(num(1, 1i).cosine_similarity(num(2, 2i))).to be_within(1e-15).of(1.0)
      expect(num(1, "a").cosine_similarity(num("a", 1) * 0.34)).to be_within(1e-15).of(1.0)
      expect(composite_number.cosine_similarity(composite_number.unit_vector))
        .to be_within(1e-15).of(1.0)
    end

    it "returns ≈-1.0 if vectors are opposite" do
      expect(num(1, 1i).cosine_similarity(num(-2, -2i))).to be_within(1e-15).of(-1.0)
      expect(num(1, "a").cosine_similarity(num("a", 1) * -0.34)).to be_within(1e-15).of(-1.0)
      expect(composite_number.cosine_similarity(composite_number.unit_vector * -1))
        .to be_within(1e-15).of(-1.0)
    end

    it "raises ZeroDivisionError if either vector is a zero vector" do
      expect { zero_number.cosine_similarity(num(1)) }.to raise_error(ZeroDivisionError)
      expect { num(1).cosine_similarity(zero_number) }.to raise_error(ZeroDivisionError)
    end

    it "automatically promotes other to a VectorNumber" do
      expect(real_number.cosine_similarity(2)).to eq real_number.cosine_similarity(num(2))
      expect(complex_number.cosine_similarity(1i)).to eq complex_number.cosine_similarity(num(1i))
      expect(composite_number.cosine_similarity(:a))
        .to eq composite_number.cosine_similarity(num(:a))
    end
  end

  describe "#jaccard_index" do
    it "returns jaccard index similarity between two vectors" do
      expect(real_number.jaccard_index(num(2))).to eq 1r
      expect(complex_number.jaccard_index(num(-0.12))).to eq 1/2r
      expect(composite_number.jaccard_index(num("y", :a, :b))).to eq 2/5r
    end

    it "returns 1r if other is the same vector" do
      expect(real_number.jaccard_index(real_number)).to eq 1r
      expect(complex_number.jaccard_index(complex_number)).to eq 1r
      expect(composite_number.jaccard_index(composite_number)).to eq 1r
    end

    it "returns 1r if other is an equal vector" do
      expect(real_number.jaccard_index(num(999.15))).to eq 1r
      expect(complex_number.jaccard_index(num(0.12, -13.5i))).to eq 1r
      expect(composite_number.jaccard_index(num("y", :a, 8, 6.3i))).to eq 1r
    end

    it "returns 0r if vectors don't have dimensions in common" do
      expect(num(1, 1i).jaccard_index(num(:b))).to eq 0r
      expect(num(1, "a").jaccard_index(num("b", :b))).to eq 0r
    end

    it "returns 1r if vectors are codirectional" do
      expect(num(1, 1i).jaccard_index(num(2, 2i))).to eq 1r
      expect(num(1, "a").jaccard_index(num("a", 1) * 0.34)).to eq 1r
      expect(composite_number.jaccard_index(composite_number.unit_vector)).to eq 1r
    end

    it "returns 1r if vectors are opposite" do
      expect(num(1, 1i).jaccard_index(num(-2, -2i))).to eq 1r
      expect(num(1, "a").jaccard_index(num("a", 1) * -0.34)).to eq 1r
      expect(composite_number.jaccard_index(composite_number.unit_vector * -1)).to eq 1r
    end

    it "returns 0r if either vector is a zero vector" do
      expect(zero_number.jaccard_index(num(1))).to eq 0r
      expect(num(1).jaccard_index(zero_number)).to eq 0r
    end

    it "raises ZeroDivisionError if both vectors are zero vectors" do
      expect { zero_number.jaccard_index(zero_number) }.to raise_error(ZeroDivisionError)
      expect { zero_number.jaccard_index(num(0)) }.to raise_error(ZeroDivisionError)
    end

    it "automatically promotes other to a VectorNumber" do
      expect(real_number.jaccard_index(2)).to eq real_number.jaccard_index(num(2))
      expect(complex_number.jaccard_index(1i)).to eq complex_number.jaccard_index(num(1i))
      expect(composite_number.jaccard_index(:a)).to eq composite_number.jaccard_index(num(:a))
    end
  end

  describe "#jaccard_similarity" do
    it "returns weighted jaccard similarity between two vectors" do
      expect(real_number.jaccard_similarity(num(999.15 * 2))).to eq 1/2r
      expect(complex_number.jaccard_similarity(num(-0.12)))
        .to eq Rational(-122_678_053_849_572_304, 1_080_863_910_568_919)
      expect(composite_number.jaccard_similarity(num("y", :a, :b)))
        .to eq Rational(562_949_953_421_312, 4_869_517_097_094_349)
    end

    it "returns 1r if other is the same vector" do
      expect(real_number.jaccard_similarity(real_number)).to eq 1r
      expect(complex_number.jaccard_similarity(complex_number)).to eq 1r
      expect(composite_number.jaccard_similarity(composite_number)).to eq 1r
    end

    it "returns 1r if other is an equal vector" do
      expect(real_number.jaccard_similarity(num(999.15))).to eq 1r
      expect(complex_number.jaccard_similarity(num(0.12, -13.5i))).to eq 1r
      expect(composite_number.jaccard_similarity(num("y", :a, 8, 6.3i))).to eq 1r
    end

    it "returns 0r if vectors don't have dimensions in common" do
      expect(num(1, 1i).jaccard_similarity(num(:b))).to eq 0r
      expect(num(1, "a").jaccard_similarity(num("b", :b))).to eq 0r
    end

    it "returns positive value if vectors are codirectional" do
      expect(num(1, 1i).jaccard_similarity(num(2, 2i))).to eq 1/2r
      expect(num(1, "a").jaccard_similarity(num("a", 1) * 0.25)).to eq 1/4r
      expect(composite_number.jaccard_similarity(composite_number.unit_vector))
        .to eq Rational(1_785_132_425_417_303, 18_352_168_481_534_772)
    end

    it "returns negative value if vectors are opposite" do
      expect(num(1, 1i).jaccard_similarity(num(-2, -2i))).to eq(-2r)
      expect(num(1, "a").jaccard_similarity(num("a", 1) * -0.25)).to eq(-1/4r)
      expect(composite_number.jaccard_similarity(composite_number.unit_vector * -1))
        .to eq Rational(-1_785_132_425_417_303, 18_352_168_481_534_772)
    end

    it "returns 0r if either vector is a zero vector" do
      expect(zero_number.jaccard_similarity(num(1))).to eq 0r
      expect(num(1).jaccard_similarity(zero_number)).to eq 0r
    end

    it "raises ZeroDivisionError if both vectors are zero vectors" do
      expect { zero_number.jaccard_similarity(zero_number) }.to raise_error(ZeroDivisionError)
      expect { zero_number.jaccard_similarity(num(0)) }.to raise_error(ZeroDivisionError)
    end

    it "automatically promotes other to a VectorNumber" do
      expect(real_number.jaccard_similarity(2)).to eq real_number.jaccard_similarity(num(2))
      expect(complex_number.jaccard_similarity(1i)).to eq complex_number.jaccard_similarity(num(1i))
      expect(composite_number.jaccard_similarity(:a))
        .to eq composite_number.jaccard_similarity(num(:a))
    end
  end
end
