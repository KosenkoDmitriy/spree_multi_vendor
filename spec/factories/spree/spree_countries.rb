FactoryBot.define do
  factory :spree_country, class: Spree::Country do
    name {'USA'}
    iso_name {'USA'}
    iso {'usa'}
    iso3 {'usa'}
  end
end
