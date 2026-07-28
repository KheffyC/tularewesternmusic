class StaffMembersController < ApplicationController
  before_action :require_staff_enabled!

  def index
    @staff_members = StaffMember.where(school: @school).ordered.with_attached_photo
    @boosters = Booster.where(school: @school).order(:created_at) if @school&.boosters_enabled?
    @active_tab = params[:tab]
  end

  private

  def require_staff_enabled!
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @school&.staff_enabled?
  end
end
