require "spec_helper"

describe SolidusPaybright::ParamsHelper do
  let(:order) { build_stubbed(:order, total: 110, number: "R123456789", email: "user@example.com") }
  let(:payment_method) { build_stubbed(:paybright_payment_method, preference_source: "paybright_credentials") }
  let(:payment) { build_stubbed(:paybright_payment, order: order, payment_method: payment_method) }

  subject { described_class.new(payment) }

  describe "#new" do
    it "requires the payment parameter" do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { subject }.to_not raise_error
    end
  end

  describe "#build_redirect_params" do
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

    context "order has store credit applied" do
      before { allow(order).to receive(:total_applicable_store_credit) { 10 } }

      it "subtracts the credit from the total passed to Paybright" do
        expect(subject.build_redirect_params["x_amount"]).to eq("100.00")
      end
    end
  end
end
