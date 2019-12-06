module Spree
  class PaybrightController < Spree::BaseController
    # We can't use CSRF protection on a route that's hit by an external service
    skip_before_action :verify_authenticity_token, only: :callback, raise: false

    # Server2server call that gets parameters about the results of the Paybright
    # transaction.
    def callback
      result, message = handle_callback_params!
      status = result ? :ok : :bad_request
      render plain: message, status: status
    end

    # The user is redirected here after completing the full Paybright checkout.
    # It also gets the same parameters of #callback.
    def complete
      result, message = handle_callback_params!
      if !result
        flash[:error] = message
      end

      redirect_to redirect_path(@payment.try(:order))
    end

    # The user is redirected here after failing some intermediate step of the
    # Paybright checkout.
    def cancel
      payment = Spree::Payment.find_by(id: params[:payment_id])
      redirect_to redirect_path(payment.try(:order))
    end

    private

    def paybright_params
      params.permit(
        :x_account_id, :x_reference, :x_currency, :x_test, :x_amount,
        :x_gateway_reference, :x_timestamp, :x_result, :x_signature, :x_message
      )
    end

    def redirect_path(order)
      return cart_path unless order
      order.complete? ? order_path(order) : checkout_state_path(order.state)
    end

    def handle_callback_params!
      @payment = Spree::Payment.find_by(id: paybright_params[:x_reference])

      valid, error = SolidusPaybright::CallbackValidator.new(paybright_params).call
      unless valid
        logger.debug "Paybright: #{error}"
        return [false, error]
      end

      @payment.update_attributes!(
        response_code: paybright_params[:x_gateway_reference],
        amount: paybright_params[:x_amount]
      )

      begin
        @payment.complete!
        advance_and_complete(@payment.order)
      rescue StandardError
        if @payment.response_code.present?
          @payment.void
        end

        return [false, 'Something went wrong with the order. Your Paybright application has been voided. Try to order again.']
      end

      [true, ""]
    end

    def advance_and_complete(order)
      order.next!
      order.complete! if order.can_complete?
    end
  end
end
