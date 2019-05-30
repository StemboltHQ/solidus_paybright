# frozen_string_literal: true

module SolidusPaybright
  module PaymentDecorator
    def redirect_url
      payment_method.redirect_url(self)
    end
  end
end

Spree::Payment.include SolidusPaybright::PaymentDecorator
