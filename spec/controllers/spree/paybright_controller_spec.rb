require "spec_helper"

describe Spree::PaybrightController, type: :controller do
  let(:order) { create(:order_with_line_items, state: "payment") }
  let(:payment_method) { create(:paybright_payment_method, preference_source: "paybright_credentials") }
  let(:payment) { create(:paybright_payment, payment_method: payment_method, order: order) }
  let(:correct_params) {
    params = {
      "x_account_id" => "api-key",
      "x_reference" => payment.id,
      "x_currency" => "CAD",
      "x_test" => "true",
      "x_amount" => "110.00",
      "x_gateway_reference" => "12345",
      "x_timestamp" => "2014-03-24T12:15:41Z",
      "x_result" => "completed",
      "x_message" => "Some message"
    }

    signature = SolidusPaybright::SigningHelper.new("api-token").params_signature(params)
    params.merge("x_signature" => signature)
  }

  let(:failed_result_params) {
    params = {
      "x_account_id" => "api-key",
      "x_reference" => payment.id,
      "x_currency" => "CAD",
      "x_test" => "true",
      "x_amount" => "110.00",
      "x_gateway_reference" => "12345",
      "x_timestamp" => "2014-03-24T12:15:41Z",
      "x_result" => "failed",
      "x_message" => "Some error"
    }

    signature = SolidusPaybright::SigningHelper.new("api-token").params_signature(params)
    params.merge("x_signature" => signature)
  }

  describe "#callback" do
    context "with a bad signature param" do
      it "returns 400 bad request" do
        request = post :callback, params: {
          x_reference: payment.id,
          x_signature: "wrong"
        }

        expect(request).to have_http_status(:bad_request)
      end
    end

    context "with a wrong payment id" do
      it "returns 400 bad request" do
        request = post :callback, params: {
          x_reference: 0
        }

        expect(request).to have_http_status(:bad_request)
      end
    end

    context "with a negative result code" do
      it "returns 204 no content" do
        request = post :callback, params: failed_result_params

        expect(request).to have_http_status(:no_content)
        expect(order.state).to eq("payment")
      end
    end

    context "if the order is already completed" do
      before do
        allow_any_instance_of(Spree::Order).to receive_messages(complete?: true)
      end

      it "returns 409 conflict" do
        request = post :callback, params: {
          x_reference: payment.id
        }

        expect(request).to have_http_status(:conflict)
      end
    end

    context "with valid data" do
      before do
        request = post :callback, params: correct_params
        expect(request).to have_http_status(:created)
        expect(order.state).to eq("payment")
      end

      it "creates a confirmed payment" do
        expect(payment.reload.state).to eq("completed")
        expect(payment.source).to be_present
      end

      it "completes the order" do
        expect(order.reload.state).to eq("complete")
      end
    end
  end

  describe "GET complete" do
    context "with a valid order number" do
      it "redirects to the order checkout step" do
        expect(
          get(:complete, params: {
            x_reference: payment.id
          })
        ).to redirect_to "http://test.host/checkout/payment"
      end
    end

    context "with a invalid order number" do
      it "redirects to the cart" do
        expect(
          get(:complete, params: {
            x_reference: 0
          })
        ).to redirect_to "http://test.host/cart"
      end
    end
  end

  describe "GET cancel" do
    context "with a valid order number" do
      it "redirects to the order checkout step" do
        expect(
          get(:cancel, params: { payment_id: payment.id })
        ).to redirect_to "http://test.host/checkout/payment"
      end
    end

    context "with a invalid order number" do
      it "redirects to the cart" do
        expect(
          get(:cancel, params: { payment_id: 0 })
        ).to redirect_to "http://test.host/cart"
      end
    end
  end
end
