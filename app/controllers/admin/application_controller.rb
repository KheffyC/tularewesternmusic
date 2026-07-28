# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_director!
    before_action :set_school
    helper ApplicationHelper
    helper_method :donations_enabled?, :stripe_pricing_table_ready?, :stripe_buy_button_ready?
    
    # Use custom admin layout with modern design
    layout "admin"

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    private

    def donations_enabled?
      stripe_pricing_table_ready? || stripe_buy_button_ready?
    end

    def set_school
      @school = School.first
    end

    def stripe_pricing_table_ready?
      stripe_publishable_key_valid? && stripe_pricing_table_id_valid?
    end

    def stripe_buy_button_ready?
      stripe_publishable_key_valid? && stripe_buy_button_id_valid?
    end

    def stripe_publishable_key_valid?
      value = STRIPE_PUBLISHABLE_KEY.to_s.strip
      valid_stripe_value?(value) && value.match?(/\Apk_(test|live)_[A-Za-z0-9]+\z/)
    end

    def stripe_pricing_table_id_valid?
      value = STRIPE_PRICING_TABLE_ID.to_s.strip
      valid_stripe_value?(value) && value.match?(/\Aprctbl_[A-Za-z0-9]+\z/)
    end

    def stripe_buy_button_id_valid?
      value = STRIPE_BUY_BUTTON_ID.to_s.strip
      valid_stripe_value?(value) && value.match?(/\Abuy_btn_[A-Za-z0-9]+\z/)
    end

    def valid_stripe_value?(value)
      return false if value.blank?

      cleaned = value.to_s.strip
      return false if cleaned.empty?

      !cleaned.match?(/\A(change|replace|your|todo|tbd|example|placeholder|dummy)[-_ ]?/i)
    end
  end
end
