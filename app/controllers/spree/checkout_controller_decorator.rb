# frozen_string_literal: true

module SolidusPaybright
  module CheckoutControllerDecorator
    def update
      if SolidusSupport.solidus_gem_version >= Gem::Version.new("2.2.0")
        update_v2_2
      else
        update_v1_2
      end
    end

    private

    def update_v2_2
      if update_order

        assign_temp_address
        return if follow_payment_redirect

        unless transition_forward
          redirect_on_failure
          return
        end

        if @order.completed?
          finalize_order
        else
          send_to_next_state
        end

      else
        render :edit
      end
    end

    def update_v1_2
      if Spree::OrderUpdateAttributes.new(@order, update_params, request_env: request.headers.env).apply
        @order.temporary_address = !params[:save_user_address]
        return if follow_payment_redirect

        success = if @order.state == 'confirm'
          @order.complete
        else
          @order.next
        end
        if !success
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(checkout_state_path(@order.state)) && return
        end

        if @order.completed?
          @current_order = nil
          flash.notice = Spree.t(:order_processed_successfully)
          flash['order_completed'] = true
          redirect_to completion_route
        else
          redirect_to checkout_state_path(@order.state)
        end
      else
        render :edit
      end
    end

    def follow_payment_redirect
      return unless params[:state] == "payment"

      payment = @order.payments.valid.last
      if redirect_url = payment.try(:redirect_url)
        redirect_to redirect_url
        true
      end
    end
  end
end

Spree::CheckoutController.prepend SolidusPaybright::CheckoutControllerDecorator
