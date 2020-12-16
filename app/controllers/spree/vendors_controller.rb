class Spree::VendorsController < Spree::StoreController
  
  def new
    # @countries_array = Spree::Country.all.map { |country| [country.name, country.id] }
    # @states_array = Spree::State.all.map { |state| [state.name, state.id] }
    @vendor = Spree::Vendor.new
  end

  def create
    if user_params[:password] != user_params[:password_confirmation]
      flash[:error] = 'password confirmation does not match password'
      render action: 'new'
      return
    end
    
    if Spree::User.exists?(email: user_params[:email])
      @user = Spree::User.find_by(email: user_params[:email])
      if !@user.valid_password?(user_params[:password])
        flash[:error] = 'Invalid password'
        render action: 'new'
        return
      end
    else
      @user = Spree::User.new(user_params)
    end
    
    @user.spree_roles << Spree::Role.find_or_create_by(name: 'vendor') if !@user.has_spree_role?('vendor')
    @stock_location = Spree::StockLocation.new(stock_location_params)
    @vendor = Spree::Vendor.new(vendor_params)
    if @user.valid? && @vendor.valid? && @stock_location.valid?
      @user.save  
      @vendor.contact_us = contact_details_params.to_h.map{|key,value| key + ': ' + value }.join("\n")
      @vendor.users << @user
      begin
        @vendor.build_image(attachment: all_params[:image])
      rescue
      end
      if @vendor.save
        # @vendor.stock_locations = [@stock_location]
        last_stock_location = @vendor.stock_locations.last
        last_stock_location.update_attributes(stock_location_params)
        last_stock_location.update(state_name: last_stock_location.name)
        flash[:notice] = I18n.t(:'devise.user_registrations.inactive_signed_up', reason: 'not yet activated')
        redirect_to root_path
      else
        flash.now[:error] = 'error - can not create the vendor'
      end
    else
      @vendor.valid?
      @user.valid?
      @stock_location.valid?
      message=''
      if @vendor.errors.any?
        message += 'Vendor Account Details: ' + @vendor.errors.full_messages.compact * ' and ' + '. '
      end
      if @user.errors.any?
        message += 'Account Details: ' + @user.errors.full_messages.compact * ' and ' + '. '
      end
      if @stock_location.errors.any?
        message += 'Stock Location: ' + @stock_location.errors.full_messages.compact * ' and ' + '. '
      end
      flash.now[:error] = message
      render action: 'new'
    end
  end

  private
  def all_params
    params.require(:spree_vendor).permit(:name, :about_us, :image, :notification_email,
      contact_details_attributes: [:name, :surname, :job_title, :email, :phone, :website], 
      stock_location: [:name, :active, :default, :backorderable_default, :propagate_all_variants, :address1, :city, :address2, :zipcode, :phone, :country_id, :state_id], 
      user: [:email, :password, :password_confirmation]
    )
  end

  def contact_details_params
    params.require(:spree_vendor).require(:contact_details_attributes).permit(:name, :surname, :job_title, :email, :phone, :website)
  end

  def vendor_params
    params.require(:spree_vendor).permit(:name, :image, :notification_email, :state, :slug, :about_us, :contact_us).except(:contact_details_attributes, :stock_location, :user, :image)
  end

  def user_params
    params.require(:spree_vendor).require(:user).permit(:email, :password, :password_confirmation)
  end

  def stock_location_params
    params.require(:spree_vendor).require(:stock_location).permit(:name, :default, :active, :backorderable_default, :propagate_all_variants, :address1, :city, :address2, :zipcode, :phone, :country_id, :state_id)
  end
end
