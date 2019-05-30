# frozen_string_literal: true

require "spec_helper"

describe Spree::PaymentMethod::Paybright, type: :model do
  let(:payment_method) { create(:paybright_payment_method, preference_source: "paybright_credentials") }
  let(:payment) { create(:paybright_payment, payment_method: payment_method) }

  it "has a valid factory" do
    expect(build(:paybright_payment_method)).to be_valid
  end

  it "has a valid payment factory " do
    expect(build(:paybright_payment)).to be_valid
  end

  describe "#redirect_url" do
    before do
      allow_any_instance_of(Spree::Order).to receive_messages(total: 110)
    end

    context "When in test mode" do
      it "returns the test URL with params" do
        expect(
          payment_method.redirect_url(payment)
        ).to start_with(
          "https://sandbox.paybright.com/CheckOut/AppForm.aspx?x_account_id=api-key&x_amount=110.00&x_currency=USD&"
        )
      end
    end

    context "When not in test mode" do
      before do
        allow(payment_method).to receive_messages preferred_test_mode: false
      end

      it "returns the live URL with params" do
        expect(
          payment_method.redirect_url(payment)
        ).to start_with(
          "https://app.paybright.com/checkout/appform.aspx?x_account_id=api-key&x_amount=110.00&x_currency=USD&"
        )
      end
    end
  end

  describe "#actions" do
    it "returns the supported actions" do
      expect(payment_method.actions).to eq(["void", "credit"])
    end
  end

  describe "#void" do
    it "calls the API client" do
      expect_any_instance_of(
        SolidusPaybright::ApiClient
      ).to receive(:void!).with("transaction-id").and_return(true)

      response = payment_method.void("transaction-id")
      expect(response).to be_success
    end
  end

  describe "#credit" do
    it "calls the API client" do
      expect_any_instance_of(
        SolidusPaybright::ApiClient
      ).to receive(:refund!).with("transaction-id", 123.45).and_return(true)

      response = payment_method.credit(123_45, "transaction-id")
      expect(response).to be_success
    end
  end
end
