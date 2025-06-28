# frozen_string_literal: true

RSpec.describe "Float#ceil" do
  it "returns the ceiling of 999.15 correctly" do
    expect(999.15.ceil).to eq 1000
    expect(999.15.ceil(1)).to eq 999.2
    expect(999.15.ceil(-1)).to eq 1000
  end

  it "returns the ceiling of 1.25 correctly" do
    expect(1.25.ceil).to eq 2
    expect(1.25.ceil(1)).to eq 1.3
    expect(1.25.ceil(-1)).to eq 10
  end

  it "returns the ceiling of -999.15 correctly" do
    expect(-999.15.ceil).to eq(-999)
    expect(-999.15.ceil(1)).to eq(-999.1)
    expect(-999.15.ceil(-1)).to eq(-990)
  end

  it "returns the ceiling of -1.25 correctly" do
    expect(-1.25.ceil).to eq(-1)
    expect(-1.25.ceil(1)).to eq(-1.2)
    expect(-1.25.ceil(-1)).to eq(0)
  end
end

RSpec.describe "Kernel#Rational" do
  let(:value) { Object.new }

  before do
    def value.to_r
      1r
    end
  end

  it "calls #to_r on the argument" do
    expect(Rational(value)).to eql 1r
  end
end
