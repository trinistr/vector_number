# frozen_string_literal: true

RSpec.describe "Kernel#Rational" do
  subject(:result) { Rational(A.new(value)) }

  a =
    Class.new do
      def initialize(value)
        @value = value
      end

      def to_r
        @value.zero? ? @value : raise(ZeroDivisionError)
      end
    end

  before { stub_const("A", a) }

  context "when #to_r works" do
    let(:value) { 0r }

    it "returns the value" do
      expect(result).to be value
    end
  end

  context "when #to_r fails" do
    let(:value) { 1.0 }

    it "raises ZeroDivisionError" do
      expect { result }.to raise_error ZeroDivisionError
    end

    context "with exception: false" do
      subject(:result) { Rational(A.new(value), exception: false) }

      it "returns nil" do
        expect(result).to be nil
      end
    end
  end
end
