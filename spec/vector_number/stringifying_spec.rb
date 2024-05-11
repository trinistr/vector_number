# frozen_string_literal: true

RSpec.describe VectorNumber::Stringifying, :aggregate_failures do
  let(:zero_number) { num(13.i, -10.5ri, -2.5i) }
  let(:real_number) { num(567/123r) }
  let(:negative_number) { num(Complex(0, -3), -5) }
  let(:composite_number) { num("y", :a, 5, -36) }

  describe "#to_s" do
    context "when no options are passed" do
      subject(:string) { number.to_s }

      context "with zero" do
        let(:number) { zero_number }

        it "returns 0" do
          expect(string).to eq "0"
        end
      end

      context "with simple number" do
        let(:number) { real_number }

        it "returns number as a string" do
          expect(string).to eq "189/41"
        end
      end

      context "with negative number" do
        let(:number) { negative_number }

        it "formats minuses appropiately" do
          expect(string).to eq "-5 - 3i"
        end
      end

      context "with composite number" do
        let(:number) { composite_number }

        it "formats every value appropiately" do
          expect(string).to eq "1⋅'y' + 1⋅a - 31"
        end
      end
    end

    context "when :mult option is passed" do
      subject(:string) { composite_number.to_s(mult:) }

      context "with one of the predefined options" do
        let(:mult) { described_class::MULT_STRINGS.keys.sample }
        let(:char) { described_class::MULT_STRINGS[mult] }

        it "inserts multiplication symbol properly" do
          expect(string).to eq "1#{char}'y' + 1#{char}a - 31"
        end
      end

      context "with a free-form string" do
        let(:mult) { char }
        let(:char) { %w[* & ^ @ !].sample(rand(1..3)).shuffle.join }

        it "inserts whatever user provided" do
          expect(string).to eq "1#{char}'y' + 1#{char}a - 31"
        end
      end
    end
  end

  describe "#inspect" do
    subject(:string) { number.inspect }

    let(:number) { [zero_number, real_number, negative_number, composite_number].sample }

    it "returns string representation surrounded by brackets" do
      expect(string).to eq "(#{number})"
    end
  end
end
