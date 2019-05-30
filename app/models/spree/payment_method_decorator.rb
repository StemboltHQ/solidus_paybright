# frozen_string_literal: true

module SolidusPaybright
  module PaymentMethodDecorator
    def redirect_url(_payment)
      nil
    end
  end
end

Spree::PaymentMethod.include SolidusPaybright::PaymentMethodDecorator
