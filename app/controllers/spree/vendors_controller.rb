class Spree::VendorsController < Spree::StoreController
  def show
  end

  def index
  end

  def new
    # @countries_array = Spree::Country.all.map { |country| [country.name, country.id] }
    # @states_array = Spree::State.all.map { |state| [state.name, state.id] }
    @vendor = Spree::Vendor.new
    # @vendor.build(:stock_locations)
    # @vendor.build_image
  end

  def create2
    # @user = Spree::User.new(user_params)
    # @user.spree_roles << Spree::Role.find_or_create_by(name: 'vendor') if !@user.has_spree_role?('vendor')
    # @user.phone_number = contact_details_params[:phone]
    @stock_location = Spree::StockLocation.new(stock_location_params)
    # if Spree::Vendor.exists?(name: vendor_params[:name])
    #   @vendor = Spree::Vendor.find_by(name: vendor_params[:name])
    # else
      @vendor = Spree::Vendor.new(vendor_params)
    # end

    if all_params[:image].present?
      params[:uploaded_file] = all_params[:image].read # File contents
      params[:uploaded_file_original_filename] = all_params[:image].original_filename
      params[:uploaded_file_headers] = all_params[:image].headers
      params[:uploaded_file_content_type] = all_params[:image].content_type
      # @vendor.build_image(attachment: all_params[:image]) 
    elsif params[:uploaded_file].present? # a file coming through the form-resubmit
      # generate an ActionDispatch::Http::UploadedFile
      # tempfile = Tempfile.new("#{params[:uploaded_file_original_filename]}-#{Time.now}")
      filename = params[:uploaded_file_original_filename]
      tempfile = Tempfile.new("#{filename}")
      tempfile.binmode
      tempfile.write StringIO.new(CGI.unescape(params[:uploaded_file])) #content of the file / unescaped
      tempfile.close
      file = ActionDispatch::Http::UploadedFile.new(
        content_type: params[:uploaded_file_content_type],
        headers: params[:uploaded_file_headers],
        original_filename: params[:uploaded_file_original_filename],
        tempfile: tempfile,
        filename: params[:uploaded_file_original_filename],
        head: params[:uploaded_file_headers],
        type: params[:uploaded_file_content_type]
      )

      # merge into the params
      ## @vendor.build_image.attachment.attach(io: StringIO.new(CGI.unescape(params[:uploaded_file])), filename: filename, content_type: params[:uploaded_file_content_type])
      # @vendor.build_image(attachment: file)
      params[:spree_vendor] = params[:spree_vendor].merge!(image: file)
    end

    @vendor.build_image(attachment: all_params[:image])

    @stock_location.name = 'name'
    @vendor.name = "name#{Spree::Vendor.count + 1}"
    @vendor.save!
    @vendor.valid?
    # @user.valid?
    if @stock_location.valid? && @vendor.valid?
      flash[:notice] = 'valid' 
    else
      message=''
      if @vendor.errors.any?
        message += 'Vendor Account Details: ' + @vendor.errors.full_messages.compact * ' and ' + '. '
      end
      # if @user.errors.any?
      #   message += 'Account Details: ' + @user.errors.full_messages.compact * ' and ' + '. '
      # end
      if @stock_location.errors.any?
        message += 'Stock Location: ' + @stock_location.errors.full_messages.compact * ' and ' + '. '
      end
      flash[:error] = message
    end
    render action: 'new'
  end

  def create
    @user = Spree::User.new(user_params)
    @user.spree_roles << Spree::Role.find_or_create_by(name: 'vendor') if !@user.has_spree_role?('vendor')
    # @user.phone_number = contact_details_params[:phone] # twilio ask for a new phone number during verification process
    @stock_location = Spree::StockLocation.new(stock_location_params)
    @vendor = Spree::Vendor.new(vendor_params)

    # remember vendor's image after validation error
    if all_params[:image].present?
      params[:uploaded_file] = all_params[:image].read # File contents
      params[:uploaded_file_original_filename] = all_params[:image].original_filename
      params[:uploaded_file_headers] = all_params[:image].headers
      params[:uploaded_file_content_type] = all_params[:image].content_type
    elsif params[:uploaded_file].present? # a file coming through the form-resubmit
      # generate an ActionDispatch::Http::UploadedFile
      filename = params[:uploaded_file_original_filename]
      tempfile = Tempfile.new("#{filename}-#{Time.now}")
      tempfile.binmode
      tempfile.write StringIO.new(CGI.unescape(params[:uploaded_file])) #content of the file / unescaped
      tempfile.close
      file = ActionDispatch::Http::UploadedFile.new(
        content_type: params[:uploaded_file_content_type],
        headers: params[:uploaded_file_headers],
        original_filename: params[:uploaded_file_original_filename],
        tempfile: tempfile,
        filename: params[:uploaded_file_original_filename],
        head: params[:uploaded_file_headers],
        type: params[:uploaded_file_content_type]
      )
      # merge into the params
      params[:spree_vendor] = params[:spree_vendor].merge!(image: file)
    end

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
        # last_stock_location.update(state_name: last_stock_location.name)
        flash[:notice] = I18n.t(:'spree.vendor_registrations.inactive_signed_up')
        redirect_to root_path
        return
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
