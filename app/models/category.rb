class Category
  include Mongoid::Document
  field :path ,type:String
  field :name,type:String
  field :category_groups,type:String
end
