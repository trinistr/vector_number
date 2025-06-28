# frozen_string_literal: true

RSpec.describe "Float#ceil" do
  it "returns the ceiling of the number" do
    expect(999.15.ceil).to eq 1000
    expect(999.15.ceil(1)).to eq 999.2
    expect(999.15.ceil(-1)).to eq 1000
  end
end
