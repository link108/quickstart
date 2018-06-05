require 'clearbit'

module ClearbitClient

  ::Clearbit.key = ENV['CLEARBIT_KEY']
  
  def self.get_company_info(name)
    company_name_info = ClearbitClient.get_company_by_name(name)
    return unless company_name_info
    ClearbitClient.get_detailed_company_info(company_name_info[:domain])
  end

  def self.get_company_by_name(name)
    Clearbit::NameDomain.find(name: name)
  end
  
  def self.get_detailed_company_info(domain)
    Clearbit::Enrichment::Company.find(domain: domain, stream: true)
  end
  
end
