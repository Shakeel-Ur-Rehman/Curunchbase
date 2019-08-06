Rails.application.routes.draw do
  get "organizations/insertRawsecond",to:"organizations#insertRawsecond"
  get "organizations/getTop100",to:"organizations#getTop100"
  get "organizations/insertRaw",to:"organizations#insertRaw"
  resources :organizations
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
