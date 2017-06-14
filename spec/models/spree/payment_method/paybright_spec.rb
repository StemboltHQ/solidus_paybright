require "spec_helper"

describe Spree::PaymentMethod::Paybright, type: :model do
  it "has a valid factory" do
    expect(build(:paybright_payment_method)).to be_valid
  end

  it "has a valid payment factory " do
    expect(build(:paybright_payment)).to be_valid
  end
end
