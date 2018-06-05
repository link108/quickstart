require 'plaid'
require 'pry-byebug'

module PlaidClient

  CLIENT = Plaid::Client.new(env: :sandbox,
                           client_id: ENV['PLAID_CLIENT_ID'],
                           secret: ENV['PLAID_SECRET'],
                           public_key: ENV['PLAID_PUBLIC_KEY'])

  DAYS_BETWEEN_RECURRING_PAYMENTS = [13, 14, 15, 16, 25, 26, 27, 28, 29, 30, 31] 

  def self.get_transactions(access_token, start_date, end_date)

    begin
      transaction_response = CLIENT.transactions.get(access_token, start_date, end_date)
    rescue
      # TODO (cmotevasselani): add error logging
      return
    end
    transactions = transaction_response.transactions

    # the transactions in the response are paginated, so make multiple calls while
    # increasing the offset to retrieve all transactions
    while transactions.length < transaction_response['total_transactions']
      begin
        transaction_response = CLIENT.transactions.get(access_token, start_date, end_date, offset: transactions.length)
      rescue
        # TODO (cmotevasselani): add error logging
        return transactions
      end
      transactions += transaction_response.transactions
    end

    return transactions
  end

  # Expects array of strings of dates
  def self.get_average_num_days_between_payments(dates)
    return nil if dates.nil? || dates.count == 1
    (dates.map {|d| Date.parse(d)}.each_cons(2).map { |start_date, end_date| start_date - end_date }.sum / dates.count).to_i
  end

  def self.is_recurring_payment?(average_days_between_payments, amounts)
    return false unless amounts.uniq.count == 1
    return DAYS_BETWEEN_RECURRING_PAYMENTS.include?(average_days_between_payments)
  end

  def self.derived_info(transactions)
    dates = transactions&.map(&:date)
    amounts = transactions&.map(&:amount)
    average_days_between_payments = get_average_num_days_between_payments(dates)
    info = { 'average_days_between_payments' => average_days_between_payments }
    info['recurring_payment'] = is_recurring_payment?(average_days_between_payments, amounts)
    return info
  end

end
