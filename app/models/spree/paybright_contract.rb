module Spree
  class PaybrightContract < ActiveRecord::Base
    has_many :payments, as: :source

    # @return [Array<String>] the actions available on this payment source
    def actions
      %w(void credit)
    end

    # Indicates whether this payment source can be used more than once. E.g. a
    # credit card with a 'payment profile'.
    def reusable?
      false
    end
  end
end
