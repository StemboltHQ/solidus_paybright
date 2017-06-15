FactoryGirl.define do
  factory :paybright_payment_method, class: Spree::PaymentMethod::Paybright do
    name "Paybright"
  end

  factory :paybright_payment, class: Spree::Payment do
    association(:payment_method, factory: :paybright_payment_method)
    order
    factory :paybright_payment_with_source do
      association(:source, factory: :paybright_contract)
    end
  end

  factory :paybright_contract, class: Spree::PaybrightContract do
    account_id "12345"
    currency "CAD"
    test true
    amount 110.00
    gateway_reference "ABCDE"
    result "completed"
    message "Some message"
  end
end
