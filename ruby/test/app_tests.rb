ENV['RACK_ENV'] = 'test'

require 'sinatra'
require_relative '../app'
require 'test/unit'
require 'rack/test'
require "mocha/test_unit"
require_relative '../lib/plaid_client'
require_relative '../lib/clearbit_client'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_transactions
    PlaidClient
      .expects(:get_transactions)
      .returns([OpenStruct.new({"account_id"=>"qdx5lP4jZ6tWppBZl4xEinLm83VZJGCdq3VaQ", "account_owner"=>nil, "amount"=>25, "category"=>["Payment", "Credit Card"], "category_id"=>"16001000", "date"=>"2017-01-01", "iso_currency_code"=>"USD", "location"=>{"address"=>nil, "city"=>nil, "lat"=>nil, "lon"=>nil, "state"=>nil, "store_number"=>nil, "zip"=>nil}, "name"=>"CREDIT CARD 3333 PAYMENT *//", "payment_meta"=>{"by_order_of"=>nil, "payee"=>nil, "payer"=>nil, "payment_method"=>nil, "payment_processor"=>nil, "ppd_id"=>nil, "reason"=>nil, "reference_number"=>nil}, "pending"=>false, "pending_transaction_id"=>nil, "transaction_id"=>"aW5JkvN3qRUKDDXmbJzrcmgB9dvDbzI7MgWGy", "transaction_type"=>"special", "unofficial_currency_code"=>nil})])
    ClearbitClient.expects(:get_company_info).returns({"id"=>"61fe3195-8c0d-427c-ae75-bc02a49fde07", "name"=>"Touchstone Climbing", "legalName"=>nil, "domain"=>"touchstoneclimbing.com", "domainAliases"=>[], "site"=>{"phoneNumbers"=>["+1 925-602-1000", "+1 510-981-9900", "+1 415-550-0515", "+1 916-341-0100"], "emailAddresses"=>["team@touchstoneclimbing.com"]}, "category"=>{"sector"=>"Consumer Discretionary", "industryGroup"=>"Consumer Discretionary", "industry"=>"Consumer Discretionary", "subIndustry"=>"Consumer Discretionary", "sicCode"=>"58", "naicsCode"=>"72"}, "tags"=>["B2C", "Consumer Discretionary", "E-commerce", "Sporting Goods"], "description"=>"California's largest community of indoor climbing and fitness gyms.", "foundedYear"=>1995, "location"=>"2295 Harrison St, San Francisco, CA 94110, USA", "timeZone"=>"America/Los_Angeles", "utcOffset"=>-7, "geo"=>{"streetNumber"=>"2295", "streetName"=>"Harrison Street", "subPremise"=>nil, "city"=>"San Francisco", "postalCode"=>"94110", "state"=>"California", "stateCode"=>"CA", "country"=>"United States", "countryCode"=>"US", "lat"=>37.76075660000001, "lng"=>-122.4124817}, "logo"=>"https://logo.clearbit.com/touchstoneclimbing.com", "facebook"=>{"handle"=>"touchstoneclimbing", "likes"=>5146}, "linkedin"=>{"handle"=>"company/touchstone-climbing"}, "twitter"=>{"handle"=>"TouchstoneClimb", "id"=>"41917663", "bio"=>"We are 11 climbing gyms located throughout California. Biggest and bestest baby!", "followers"=>4015, "following"=>549, "location"=>"California", "site"=>"https://t.co/0N2mT5Ge8r", "avatar"=>"https://pbs.twimg.com/profile_images/761601154174169088/bghJubNr_normal.jpg"}, "crunchbase"=>{"handle"=>"organization/touchstone-climbing"}, "emailProvider"=>false, "type"=>"private", "ticker"=>nil, "identifiers"=>{"usEIN"=>nil}, "phone"=>nil, "metrics"=>{"alexaUsRank"=>24163, "alexaGlobalRank"=>120200, "employees"=>150, "employeesRange"=>"51-250", "marketCap"=>nil, "raised"=>nil, "annualRevenue"=>nil, "estimatedAnnualRevenue"=>"$10M-$50M", "fiscalYearEnd"=>nil}, "indexedAt"=>"2018-05-22T02:21:02.512Z", "tech"=>["wordpress", "crazy_egg", "nginx", "google_cloud", "youtube", "google_analytics", "google_apps", "recaptcha", "gravity_forms", "google_maps", "instagram", "google_tag_manager"], "parent"=>{"domain"=>nil}})
    get '/transactions'
    assert last_response.ok?
  end

end
