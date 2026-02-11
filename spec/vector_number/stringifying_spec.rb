# frozen_string_literal: true

RSpec.describe VectorNumber do
  let(:zero_number) { num(13.i, -10.5ri, -2.5i) }
  let(:real_number) { num(567/123r) }
  let(:negative_number) { num(Complex(0, -3), -5) }
  let(:composite_number) { num("y", :a, 5, -36) }

  let(:my_basic_class) { Class.new(BasicObject) { define_method(:hash, -> { 1 }) } }

  describe "#to_s" do
    subject(:string) { number.to_s }

    context "when :mult option is not specified" do
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
          expect(string).to eq "1⋅\"y\" + 1⋅:a - 31"
        end
      end
    end

    context "when :mult option is passed" do
      subject(:string) { composite_number.to_s(mult: mult) }

      context "with one of the predefined options" do
        let(:mult) { described_class::MULT_STRINGS.keys.sample }
        let(:char) { described_class::MULT_STRINGS[mult] }

        it "inserts multiplication symbol properly" do
          expect(string).to eq "1#{char}\"y\" + 1#{char}:a - 31"
        end
      end

      context "with a free-form string" do
        let(:mult) { char }
        let(:char) { %w[* & ^ @ !].sample(rand(1..3)).shuffle.join }

        it "inserts whatever user provided" do
          expect(string).to eq "1#{char}\"y\" + 1#{char}:a - 31"
        end
      end

      context "with an object" do
        let(:mult) { [5, Object.new, num].sample }

        it "raises ArgumentError" do
          expect { string }.to raise_error ArgumentError
        end
      end
    end

    context "with a customization block" do
      subject(:string) { composite_number.to_s(&block) }

      context "when block has two parameters" do
        let(:block) { proc { |unit, coefficient| "#{coefficient}#{unit}," } }

        it "uses the block to format each unit-coefficient pair" do
          expect(string).to eq "1y,1a,-31,"
        end
      end

      context "when block has three parameters" do
        let(:block) { proc { |unit, coefficient, index| "#{index}:#{coefficient}#{unit}," } }

        it "allows to use index for extra formatting" do
          expect(string).to eq "0:1y,1:1a,2:-31,"
        end
      end

      context "when block has four parameters" do
        let(:block) do
          proc { |unit, coefficient, index, op| "#{index}:#{coefficient}#{op}#{unit}," }
        end

        it "allows to use defined multiplication operator" do
          expect(string).to eq "0:1⋅y,1:1⋅a,2:-31⋅,"
        end

        it "passes specified :mult operator to the block" do
          with_string = composite_number.to_s(mult: "#", &block)
          expect(with_string).to eq "0:1#y,1:1#a,2:-31#,"

          with_symbol = composite_number.to_s(mult: :cross, &block)
          expect(with_symbol).to eq "0:1×y,1:1×a,2:-31×,"
        end
      end
    end

    context "when a BasicObject is inside the vector" do
      let(:number) { num(value) }
      let(:value) { my_basic_class.new }

      it "fails to stringify, raising NameError" do
        expect { string }.to raise_error NameError
      end
    end
  end

  describe "#inspect" do
    subject(:string) { number.inspect }

    let(:number) { [real_number, negative_number, composite_number].sample }

    it "returns string representation surrounded by brackets" do
      expect(string).to eq "(#{number})"
    end

    it "returns (0) for a zero vector" do
      expect(zero_number.inspect).to eq "(0)"
    end
  end

  describe "#pretty_print", :pretty_print do
    subject(:string) { number.pretty_print_inspect }

    let(:number) { composite_number }

    it "outputs the same string representation as #inspect" do
      expect(number.pretty_print_inspect).to eq number.inspect
    end

    it "outputs (0) for a zero vector" do
      expect(zero_number.pretty_print_inspect).to eq "(0)"
    end
  end
end
