class PaymentsController < ApplicationController
  include Pundit::Authorization
  after_action :verify_authorized, except: [:new, :create, :prepare]

  before_action :authenticate_user!
  before_action :set_purchasable, only: [:new]
  skip_after_action :verify_authorized, :verify_policy_scoped

  def prepare
    authorize :payment, :prepare?
    purchasable = find_purchasable_from_signed_info(params[:signed_info])

    if purchasable
      session[:purchasable_type] = purchasable.class.name
      session[:purchasable_id] = purchasable.id
      redirect_to new_payment_path
    else
      redirect_to root_path, alert: "Invalid purchase request."
    end
  end

  def new
    authorize :payment, :new?
    @credit_card_payment = CreditCardPayment.new
  end

  def create
    authorize :payment, :create?
    @purchasable = find_purchasable_from_signed_info(params[:signed_info])
    if @purchasable.nil?
      redirect_to root_path, alert: "Purchasable item not found." and return
    end

    card_params = params[:credit_card_payment]
    
    # Clean and validate card number
    card_number = card_params[:card_number].to_s.gsub(/\s/, '')
    if card_number.length < 4
      @purchasable = find_purchasable_from_session
      flash.now[:alert] = "Invalid card number"
      render :new, status: :unprocessable_entity and return
    end
    
    last_four = card_number.last(4)
    
    # Validate expiry date format
    expiry_date = card_params[:expiry_date].to_s.strip
    unless expiry_date.match?(/\A(0[1-9]|1[0-2])\/\d{2}\z/)
      @purchasable = find_purchasable_from_session
      flash.now[:alert] = "Expiry date must be in MM/YY format"
      render :new, status: :unprocessable_entity and return
    end
    
    @credit_card_payment = CreditCardPayment.new(
      last_four: last_four,
      expiry_date: expiry_date,
      card_type: detect_card_type(card_number)
    )

    if @credit_card_payment.invalid?
      @purchasable = find_purchasable_from_session
      flash.now[:alert] = @credit_card_payment.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity and return
    end

    if process_purchase
      flash[:notice] = "Purchase successful!"
      redirect_to polymorphic_path(@purchasable)
    else
      @purchasable = find_purchasable_from_session
      render :new, status: :unprocessable_entity
    end
  end

  private

  def pundit_user
    current_user
  end

  def set_purchasable
    @purchasable = find_purchasable_from_session
    if @purchasable.nil?
      redirect_to root_path, alert: "Invalid purchasable item."
    end
  end

  def find_purchasable_from_signed_info(signed_info)
    return nil unless signed_info.present?
    
    verifier = Rails.application.message_verifier('purchasable-item')
    data = verifier.verify(signed_info)
    data["type"].constantize.find(data["id"])
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound, NameError
    nil
  end

  def find_purchasable_from_session
    if session[:purchasable_type] && session[:purchasable_id]
      session[:purchasable_type].constantize.find_by(id: session[:purchasable_id])
    end
  end

  def process_purchase
    ActiveRecord::Base.transaction do
      @credit_card_payment.save!
      
      if @purchasable.is_a?(Course)
        # Then create purchase
        purchase = Purchase.create!(
          student: current_user,
          course: @purchasable,
          amount: @purchasable.price,
          purchased_at: Time.current
        )
        
      elsif @purchasable.is_a?(Term)
        TermSubscription.create!(
          term: @purchasable,
          student: current_user,
          payment_method: @credit_card_payment,
          start_date: Time.current,
          end_date: Time.current + 1.year, # Placeholder
          status: 'active'
        )
      end
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    false
  end
  
  def detect_card_type(number)
    # Basic card type detection
    case number
    when /^4/
      'Visa'
    when /^5[1-5]/
      'Mastercard'
    when /^3[47]/
      'American Express'
    else
      'Unknown'
    end
  end
end 