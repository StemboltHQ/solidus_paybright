module Spree
  class PaybrightController < Spree::BaseController
    # Server2server call with the results of the Paybright transaction as
    # parameters
    def callback
      payment = Spree::Payment.find_by(id: paybright_params[:x_reference])
      unless payment
        logger.debug "Paybright: Payment id not found"
        return head :bad_request
      end

      order = payment.order
      if order.complete?
        logger.debug "Paybright: Order is already in complete state"
        return head :conflict
      end

      if !signing_helper(payment).valid_params?(paybright_params.to_hash)
        logger.debug "Paybright: Invalid parameters signature"
        return head :bad_request
      end

      if paybright_params[:x_result] != "completed"
        logger.debug "Paybright: The contract was not completed"
        return head :no_content
      end

      paybright_contract = build_paybright_contract

      paybright_contract.transaction do
        if paybright_contract.save!
          payment.update_attributes!(
            source: paybright_contract,
            amount: paybright_params[:x_amount]
          )
          payment.complete!

          order.next!
          order.complete! if order.can_complete?
        end
      end

      head :created
    end

    # The user is redirected here after completing the full Paybright checkout.
    # The result of the operation may be be positive or negative
    def complete
      payment = Spree::Payment.find_by(id: paybright_params[:x_reference])
      redirect_to order_state_checkout_path(payment.try(:order))
    end

    # The user is redirected here after failing some intermediate step of the
    # Paybright checkout.
    def cancel
      payment = Spree::Payment.find_by(id: params[:payment_id])
      redirect_to order_state_checkout_path(payment.try(:order))
    end

    private

    def paybright_params
      params.permit(
        :x_account_id, :x_reference, :x_currency, :x_test, :x_amount,
        :x_gateway_reference, :x_timestamp, :x_result, :x_signature, :x_message
      )
    end

    def build_paybright_contract
      Spree::PaybrightContract.new({
        account_id: paybright_params[:x_account_id],
        currency: paybright_params[:x_currency],
        test: paybright_params[:x_test],
        amount: paybright_params[:x_amount],
        gateway_reference: paybright_params[:x_gateway_reference],
        result: paybright_params[:x_result],
        message: paybright_params[:x_message]
      })
    end

    def signing_helper(payment)
      api_token = payment.payment_method.preferences.fetch(:api_token)
      SolidusPaybright::SigningHelper.new(api_token)
    end

    def order_state_checkout_path(order)
      order ? checkout_state_path(order.state) : cart_path
    end
  end
end
