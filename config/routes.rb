Spree::Core::Engine.routes.draw do
  resources :vendors, only: [:index, :show, :new, :create]
  namespace :admin do
    resources :vendors do
      collection do
        post :update_positions
      end
    end
    get 'vendor_settings' => 'vendor_settings#edit'
    patch 'vendor_settings' => 'vendor_settings#update'
  end
end
