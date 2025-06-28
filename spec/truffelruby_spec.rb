# frozen_string_literal: true

RSpec.describe "Float#ceil" do
  it "returns the ceiling of the number" do
    expect(1.25.ceil).to eq 2
    expect(1.25.ceil(1)).to eq 1.3
    expect(1.25.ceil(-1)).to eq 10
  end
end
