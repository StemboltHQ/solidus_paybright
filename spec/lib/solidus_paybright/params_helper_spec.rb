# frozen_string_literal: true

require "spec_helper"

describe SolidusPaybright::ParamsHelper do
  let(:payment_method) { create(:paybright_payment_method, preference_source: "paybright_credentials") }
  let(:payment) { create(:paybright_payment, payment_method: payment_method) }
  subject { described_class.new(payment) }

  describe "#new" do
    it "requires the payment parameter" do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { subject }.to_not raise_error
    end
  end

  describe "#build_redirect_params" do
    before do
      allow_any_instance_of(Spree::Order).to receive_messages(
        total: 110,
        number: "R123456789",
        email: "user@example.com"
      )
    end

    it "build the correct parameters for the order" do
      params = subject.build_redirect_params
      expect(params["x_account_id"]).to eq("api-key")
      expect(params["x_amount"]).to eq("110.00")
      expect(params["x_currency"]).to eq("USD")
      expect(params["x_reference"]).to eq(payment.id)
      expect(params["x_shop_country"]).to eq("CA")
      expect(params["x_shop_name"]).to eq("Test shop")
      expect(params["x_test"]).to eq("true")
      expect(params["x_url_callback"]).to eq("http://example.com/paybright/callback")
      expect(params["x_url_cancel"]).to eq("http://example.com/paybright/cancel/#{payment.id}")
      expect(params["x_url_complete"]).to eq("http://example.com/paybright/complete")
      expect(params["x_customer_email"]).to eq("user@example.com")
    end

    it "rejects blank parameters" do # required by Paybright
      allow_any_instance_of(Spree::Order).to receive_messages email: ""
      expect(subject.build_redirect_params.key?("x_customer_email")).to be false
    end
  end
end
