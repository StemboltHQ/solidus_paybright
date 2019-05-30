# frozen_string_literal: true

require "spec_helper"

describe Spree::CheckoutController, type: :controller do
  let(:token) { 'some_token' }
  let(:user) { create(:user) }
  let(:order) { create(:order_with_line_items) }
  let(:payment_method) { create(:check_payment_method) }

  before do
    allow(controller).to receive_messages try_spree_current_user: user
    allow(controller).to receive_messages spree_current_user: user
    allow(controller).to receive_messages current_order: order
    allow(order).to receive_messages checkout_steps: ["address", "delivery", "payment", "confirm", "complete"]
    order.update_attributes! user: user
  end

  def patch_payment
    patch :update, params: {
      state: "payment",
      order: {
        payments_attributes: [payment_method_id: payment_method.id]
      }
    }
  end

  context "PATCH #update" do
    context "Using a payment method without a redirect url" do
      it "proceed to the confirm step" do
        patch_payment
        expect(response).to redirect_to(spree.checkout_state_path(:confirm))
      end
    end

    context "Using a payment method with a redirect url" do
      before do
        allow_any_instance_of(
          Spree::PaymentMethod
        ).to receive_messages(
          has_redirect_url?: true,
          redirect_url: "http://example.com"
        )
      end

      it "redirects to the payment method site" do
        patch_payment
        expect(response).to redirect_to("http://example.com")
      end
    end
  end
end
