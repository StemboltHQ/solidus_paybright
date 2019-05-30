# frozen_string_literal: true

require "spec_helper"

describe Spree::PaybrightController, type: :controller do
  let(:order) { create(:order_with_line_items, state: "payment", number: "R123456789") }
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
      "x_result" => "Completed",
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
      "x_result" => "Failed",
      "x_message" => "Some error"
    }

    signature = SolidusPaybright::SigningHelper.new("api-token").params_signature(params)
    params.merge("x_signature" => signature)
  }

  describe "POST callback" do
    context "with a bad signature param" do
      it "returns 400 and the error" do
        request = post :callback, params: {
          x_reference: payment.id,
          x_signature: "wrong"
        }

        expect(request).to have_http_status(:bad_request)
        expect(request.body).to be_present
      end
    end

    context "with a wrong payment id" do
      it "returns 400 and the error" do
        request = post :callback, params: {
          x_reference: 0
        }

        expect(request).to have_http_status(:bad_request)
        expect(request.body).to be_present
      end
    end

    context "with a completed payment id" do
      it "returns 400 and the error" do
        allow_any_instance_of(Spree::Payment).to receive_messages(completed?: true)
        request = post :callback, params: {
          x_reference: payment.id
        }

        expect(request).to have_http_status(:bad_request)
        expect(request.body).to be_present
      end
    end

    context "with a negative result code" do
      it "returns 400 and the error" do
        request = post :callback, params: failed_result_params

        expect(request).to have_http_status(:bad_request)
        expect(request.body).to be_present
      end
    end

    context "if the order is already completed" do
      before do
        allow_any_instance_of(Spree::Order).to receive_messages(complete?: true)
      end

      it "returns 400 and the error" do
        request = post :callback, params: {
          x_reference: payment.id
        }

        expect(request).to have_http_status(:bad_request)
        expect(request.body).to be_present
      end
    end

    context "with valid successful params" do
      let!(:request) { post :callback, params: correct_params }

      it "creates a confirmed payment" do
        expect(payment.reload.state).to eq("completed")
        expect(payment.response_code).to be_present
      end

      it "completes the order" do
        expect(order.reload.state).to eq("complete")
      end

      it "respond with 200 and blank body" do
        expect(request).to have_http_status(:ok)
        expect(request.body).to be_blank
      end
    end
  end

  describe "GET complete" do
    context "with valid successful params" do
      let!(:request) { get :complete, params: correct_params }

      it "creates a confirmed payment" do
        expect(payment.reload.state).to eq("completed")
        expect(payment.response_code).to be_present
      end

      it "completes the order" do
        expect(order.reload.state).to eq("complete")
      end

      it "redirects to the order page" do
        expect(request).to redirect_to("http://test.host/orders/R123456789")
      end
    end

    context "with a valid payment number" do
      it "redirects to the order checkout step" do
        expect(
          get(:complete, params: {
            x_reference: payment.id
          })
        ).to redirect_to "http://test.host/checkout/payment"
      end
    end

    context "with a invalid payment number" do
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
    context "with a valid payment number" do
      it "redirects to the order checkout step" do
        expect(
          get(:cancel, params: { payment_id: payment.id })
        ).to redirect_to "http://test.host/checkout/payment"
      end
    end

    context "with a invalid payment number" do
      it "redirects to the cart" do
        expect(
          get(:cancel, params: { payment_id: 0 })
        ).to redirect_to "http://test.host/cart"
      end
    end
  end
end
