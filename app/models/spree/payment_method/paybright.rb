# frozen_string_literal: true

module Spree
  class PaymentMethod::Paybright < Spree::PaymentMethod
    preference :api_key, :string
    preference :api_token, :string
    preference :shop_country_code, :string
    preference :shop_name, :string
    preference :test_mode, :boolean, default: true

    def payment_source_class
      nil
    end

    def source_required?
      false
    end

    def auto_capture
      false
    end

    # @return [Array<String>] the actions available on this payment method
    def actions
      %w(void credit)
    end

    def redirect_url(payment)
      uri = URI.parse(paybright_redirect_url)
      params = SolidusPaybright::ParamsHelper.new(payment).build_redirect_params
      uri.query = params.to_query

      uri.to_s
    end

    def void(transaction_id, _gateway_options = {})
      if api_client.void!(transaction_id)
        response(
          true,
          Spree.t("paybright.successful_action", action: "void", id: transaction_id)
        )
      else
        response(
          false,
          Spree.t("paybright.unsuccessful_action", action: "void", id: transaction_id)
        )
      end
    end

    def credit(amount_in_cents, transaction_id, _gateway_options = {})
      if api_client.refund!(transaction_id, amount_in_cents / 100.0)
        response(
          true,
          Spree.t("paybright.successful_action", action: "credit", id: transaction_id)
        )
      else
        response(
          false,
          Spree.t("paybright.unsuccessful_action", action: "credit", id: transaction_id)
        )
      end
    end

    private

    def paybright_redirect_url
      if preferred_test_mode
        SolidusPaybright::Config.test_redirect_url
      else
        SolidusPaybright::Config.live_redirect_url
      end
    end

    def api_url
      if preferred_test_mode
        SolidusPaybright::Config.test_api_endpoint
      else
        SolidusPaybright::Config.live_api_endpoint
      end
    end

    def api_client
      SolidusPaybright::ApiClient.new(
        preferred_api_key,
        preferred_api_token,
        api_url
      )
    end

    def response(success, message)
      ActiveMerchant::Billing::Response.new(success, message, {}, {})
    end
  end
end
