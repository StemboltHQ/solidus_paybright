require "spec_helper"

describe Spree::PaybrightContract, type: :model do
  it "has a valid factory" do
    expect(build(:paybright_contract)).to be_valid
  end
end
