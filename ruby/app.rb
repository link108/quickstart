require 'date'
require 'sinatra'
require 'plaid'
require_relative 'lib/plaid_client'
require_relative 'lib/clearbit_client'

set :public_folder, File.dirname(__FILE__) + '/public'

client = Plaid::Client.new(env: :sandbox,
                           client_id: ENV['PLAID_CLIENT_ID'],
                           secret: ENV['PLAID_SECRET'],
                           public_key: ENV['PLAID_PUBLIC_KEY'])

access_token = nil

get '/' do
  erb :index
end

post '/get_access_token' do
  exchange_token_response = client.item.public_token.exchange(params['public_token'])
  access_token = exchange_token_response['access_token']
  item_id = exchange_token_response['item_id']
  puts "access token: #{access_token}"
  puts "item id: #{item_id}"
  exchange_token_response.to_json
end

get '/accounts' do
  auth_response = client.auth.get(access_token)
  content_type :json
  auth_response.to_json
end

get '/item' do
  item_response = client.item.get(access_token)
  institution_response = client.institutions.get_by_id(item_response['item']['institution_id'])
  content_type :json
  { item: item_response['item'], institution: institution_response['institution'] }.to_json
end

get '/transactions' do
  start_date = params[:start_date] || '2016-07-12'
  end_date = params[:end_date] || '2017-01-09'

  transactions = PlaidClient.get_transactions(access_token, start_date, end_date)
  company_name_to_info = get_company_info(transactions)
  sorted_transactions = sort_and_format_transactions(transactions, company_name_to_info)
  content_type :json
  {transactions: sorted_transactions}.to_json
end

get '/create_public_token' do
  public_token_response = client.item.public_token.exchange(access_token)
  content_type :json
  public_token_response.to_json
end

def sort_and_format_transactions(transactions, company_name_to_info)
  transactions.sort_by(&:date).reverse.map do |transaction|
    transaction.to_h.reduce({}) {|r,(k,v)| r[k.to_s] = v; r}.merge(company_name_to_info[transaction.name])
  end
end

def get_company_info(transactions)
  transactions.group_by(&:name).reduce({}) do |res, (name, values)|
    clearbit_info = ClearbitClient.get_company_info(name).to_h || {}
    derived_info = PlaidClient.derived_info(values)
    res[name] = clearbit_info.merge(derived_info)
    res
  end
end
