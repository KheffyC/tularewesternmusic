class ProgramsController < ApplicationController
  before_action :program_params, only: [:create, :update]

  private

  def program_params
    params.require(:program).permit(:name, :description, :year_established, :main_gallery_image_url, :page_image_url, :school_id)
  end
end
