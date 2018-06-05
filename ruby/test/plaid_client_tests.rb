ENV['RACK_ENV'] = 'test'

require 'test/unit'
require 'rack/test'
require_relative '../lib/plaid_client'

class PlaidClientTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_get_average_num_days_between_payments
    dates = ["2018-10-03", "2018-09-03", "2018-08-03", "2018-07-03", "2018-06-03"]
    average_num_days = PlaidClient.get_average_num_days_between_payments(dates)
    assert_equal 24, average_num_days
  end

  def test_get_average_num_days_between_payments_one_date
    dates = ["2018-10-03"]
    average_num_days = PlaidClient.get_average_num_days_between_payments(dates)
    assert_equal nil, average_num_days
  end

  def test_is_recurring_payment
    average_num_days_between_payments = 15
    amounts = [10, 10, 10, 10]
    assert_equal true, PlaidClient.is_recurring_payment?(average_num_days_between_payments, amounts)
  end

  def test_is_recurring_payment_not_recurring
    average_num_days_between_payments = 15
    amounts = [10, -10, 10, -10]
    assert_equal false, PlaidClient.is_recurring_payment?(average_num_days_between_payments, amounts)
  end
end
