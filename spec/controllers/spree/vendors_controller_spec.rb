# require 'rails_helper'
require 'spec_helper'

RSpec.describe Spree::VendorsController, type: :controller do
  
  describe 'Vendor Sign Up' do
    let (:valid_params) { {
      "spree_vendor"=> {
      "contact_details_attributes"=>
        {"name"=>"test", "surname"=>"test", "job_title"=>"test", "email"=>"test", "phone"=>"1231231", "website"=>"test.com"},
      "name"=>"test",
      "about_us"=>"test",
      "image"=> [],
      "notification_email"=>"test@email.com",
      "stock_location"=> 
      {"name"=>"Stock Name",
        "active"=>"1",
        "default"=>"1",
        "backorderable_default"=>"1",
        "propagate_all_variants"=>"1",
        "address1"=>"test",
        "city"=>"test",
        "address2"=>"test",
        "zipcode"=>"123123",
        "phone"=>"",
        "country_id"=>"233",
        "state_id"=>"2818"}, 
      "user"=>{"email"=>"test@email.com", "password"=>"[FILTERED]", "password_confirmation"=>"[FILTERED]"}
      }
      }
    }
    
    it 'new' do
      get 'new'
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end

    it 'create' do
      post :create, params: valid_params
      # expect(response).to have_text('sign') #todo: follow redirect and check flash notice 
      expect(response.status).to eq(204)
    end
  end
end