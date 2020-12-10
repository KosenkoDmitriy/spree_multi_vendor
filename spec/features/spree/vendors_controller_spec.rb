# require 'rails_helper'
require 'spec_helper'

# describe "vendor signup process", js: true do
describe "vendor signup process" do
  let(:file_name) {'logo.png'} 
  let(:file) {Rails.root.join('app','assets', 'images', file_name)} 
  let!(:country2) {FactoryBot.build(:spree_country, name: 'Canada', iso_name: 'ca', iso: 'ca', iso3: 'ca')}
  let!(:country) {FactoryBot.create(:spree_country, name: 'United Kindom')}
  let!(:state2) {FactoryBot.create(:spree_state, name: 'Ontario', country: country2)}
  let!(:state) {FactoryBot.create(:spree_state, name: 'Scotland', country: country)}
  let!(:store) {Spree::Store.create(
    name: "Spree Demo Site",
    url: "demo.spreecommerce.org",
    meta_description: "Spree Commerce is an open source Ecommerce framework decision makers want, developers enjoy.",
    meta_keywords: nil,
    seo_title: "Spree Commerce Demo Shop",
    mail_from_address: "spree@example.com",
    default_currency: "USD",
    code: "spree",
    default: true,)
  }
  let(:vendor_email) {'vendor@email.com'}
  let(:vendor_contact_email) {'vendor@contact_email.com'}
  let(:user_email) {'user@email.com'}
    
  it 'success' do
    visit '/vendors/new'

    # contact person details
    fill_in :spree_vendor_contact_details_attributes_name, with: 'Name'
    fill_in :spree_vendor_contact_details_attributes_surname, with: 'Surname'
    fill_in :spree_vendor_contact_details_attributes_job_title, with: 'Job Title'
    fill_in :spree_vendor_contact_details_attributes_email, with: vendor_contact_email
    fill_in :spree_vendor_contact_details_attributes_phone, with: 'Phone'
    fill_in :spree_vendor_contact_details_attributes_website, with: 'http://ex.com'

    # vendor account details
    fill_in :spree_vendor_name, with: 'TestVendor'
    fill_in :spree_vendor_about_us, with: 'About Vendor'
    attach_file('spree_vendor_image', file, visible: :all) # input element that has a name, id, or label_text
    fill_in :spree_vendor_notification_email, with: vendor_email
    
    # stock location
    fill_in :spree_vendor_stock_location_name, with: 'Stock Name'
    check(:spree_vendor_stock_location_active, allow_label_click: true, visible: :all)
    uncheck(:spree_vendor_stock_location_default, allow_label_click: true, visible: :all)
    uncheck(:spree_vendor_stock_location_backorderable_default, allow_label_click: true, visible: :all)
    uncheck(:spree_vendor_stock_location_propagate_all_variants, allow_label_click: true, visible: :all)
    
    fill_in :spree_vendor_stock_location_address1, with: 'Address 1'
    fill_in :spree_vendor_stock_location_city, with: 'City'
    fill_in :spree_vendor_stock_location_address2, with: 'Address 2'
    fill_in :spree_vendor_stock_location_zipcode, with: 'zip code'
    fill_in :spree_vendor_stock_location_phone, with: '+9876543210'
    select(country.name, from: :spree_vendor_stock_location_country_id, match: :first)
    select(state.name, from: :spree_vendor_stock_location_state_id, match: :first)
    
    # account details
    fill_in :spree_vendor_user_email, with: user_email
    fill_in :spree_vendor_user_password, with: 'password'
    fill_in :spree_vendor_user_password_confirmation, with: 'password'

    click_on(I18n.t('storefront.buttons.request_vendor_account'))
    expect(page).to have_text(I18n.t(:'devise.user_registrations.inactive_signed_up', reason: 'not yet activated'))
    
    user = Spree::User.last
    vendor = user.vendors.last
    stock_location = vendor.stock_locations.last
    expect(vendor.name).to eq('TestVendor')
    expect(vendor.about_us).to eq('About Vendor')
    expect(vendor.image).not_to eq(nil)
    expect(vendor.image.attachment_file_size).not_to eq(0)
    expect(vendor.notification_email).to eq(vendor_email)
    expect(vendor.contact_us).to have_text(vendor_contact_email)
    expect(user.email).to eq(user_email)
    
    expect(vendor.stock_locations.count).to eq(1)
    expect(vendor.stock_locations.last.name).to eq('Stock Name')
    expect(vendor.stock_locations.last.country).to eq(country)
    expect(vendor.stock_locations.last.state).to eq(state)
    expect(vendor.stock_locations.last.vendor).to eq(vendor)
    expect(vendor.stock_locations.last.active).to eq(true)
    expect(vendor.stock_locations.last.backorderable_default).to eq(false)
    expect(vendor.stock_locations.last.propagate_all_variants).to eq(false)
    expect(vendor.stock_locations.last.default).to eq(false)
    expect(vendor.stock_locations.last.state.name).to eq(state.name)

    expect(Spree::StockLocation.last.name).to eq('Stock Name')
  end
end