class Investor
  include Mongoid::Document
  field:name,type:String
  field :location,type: String
  field :number_of_exits ,type: Integer
  field :number_of_investments ,type: Integer
  field :number_of_portfolio_organizations ,type: Integer
  field :organization_url,type: String
end
