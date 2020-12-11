# require 'rails_helper'
require 'spec_helper'

RSpec.describe Spree::Vendor, type: :model do
  
  let!(:vendor) {Spree::Vendor.create(name: 'Name')}
  let!(:user) {Spree::User.create(email: 'test@email.com', vendors: [vendor])}
  let(:stock_location) {Spree::StockLocation.create(name:'default', vendor: vendor)}

  it 'check vendor details' do
    expect(vendor.name).to eq('Name')
    expect(vendor.state).to eq('pending')
    expect(vendor.slug).to eq('name')
    expect(vendor.about_us).to eq(nil)
    expect(vendor.contact_us).to eq(nil)
    expect(vendor.commission_rate).to eq(5)
    expect(vendor.priority).to eq(1)
    expect(vendor.deleted_at).to eq(nil)
    expect(vendor.notification_email).to eq(nil)
  end

  it 'check stock locations' do
    expect(stock_location.name).to eq('default')
    expect(stock_location.vendor).to eq(vendor)
    expect(stock_location.backorderable_default).to eq(false)
    expect(stock_location.propagate_all_variants).to eq(true)
    expect(stock_location.active).to eq(true)
    expect(stock_location.default).to eq(false)
    expect(stock_location.address1).to eq(nil)
    expect(stock_location.address2).to eq(nil)
    expect(stock_location.city).to eq(nil)
    expect(stock_location.state_id).to eq(nil)
    expect(stock_location.state_name).to eq(nil)
    expect(stock_location.country_id).to eq(nil)
    expect(stock_location.zipcode).to eq(nil)
    expect(stock_location.phone).to eq(nil)
  end
  
  it 'check user' do
    expect(user.vendors).to include(vendor)
    expect(user.email).to eq('test@email.com')
  end
end
