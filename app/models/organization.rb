require 'uri/http'
class Organization

include Mongoid::Document
  field :permalink ,type: String
field :api_path ,type: String
field :web_path ,type: String
field :name ,type: String
field :categories,type: String
field :category ,type: String
field :also_known_as ,type: String 
field :short_description ,type: String
field :description,type: String
field :profile_image_url ,type: String
field :primary_role ,type: String
field :role_company,type: Boolean
field :role_investor,type: Boolean
field :role_group,type: Boolean
field :role_school,type: Boolean
field :founded_on,type: Date
field :founded_on_trust_code,type: Integer
field :is_closed, type:Boolean
field :closed_on,type: Date
field :closed_on_trust_code, type: Integer
field :num_employees_min,type:Integer
field :num_employees_max,type:Integer
field :total_funding_usd ,type:Integer
field :stock_exchange ,type: String
field :stock_symbol ,type: String
field :number_of_investments,type:Integer
field :homepage_url ,type: String
field :permalink_aliases ,type: String
field :api_url ,type: String
field :investor_type ,type: String
field :contact_email ,type: String
field :phone_number ,type: String
field :rank,type:Integer
field :last_funding_date,type:Date
field :created_at ,type: String
field :updated_at ,type: String
def self.permalink(url)
  url.split('/').last
 end
end