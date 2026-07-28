class FundraisersController < ApplicationController
  before_action :authenticate_director!, only: %i[new create edit update destroy]
  before_action :require_feature_enabled!, only: %i[index show]
  before_action :set_fundraiser, only: %i[show edit update destroy]

  def index
    program_ids = @school.programs.pluck(:id)
    @active_fundraisers = Fundraiser.active.where(program_id: program_ids).includes(:program)
    @past_fundraisers   = Fundraiser.past.where(program_id: program_ids).includes(:program)
  end

  def show; end

  def new
    @fundraiser = Fundraiser.new
    @programs = @school.programs.order(:name)
  end

  def create
    @fundraiser = Fundraiser.new(fundraiser_params.except(:flyer))
    @fundraiser.flyer.attach(fundraiser_params[:flyer]) if fundraiser_params[:flyer].present?

    if @fundraiser.save
      redirect_to fundraisers_path, notice: 'Fundraiser created successfully.'
    else
      @programs = @school.programs.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @programs = @school.programs.order(:name)
  end

  def update
    if fundraiser_params[:flyer].present?
      @fundraiser.flyer.attach(fundraiser_params[:flyer])
    end

    if @fundraiser.update(fundraiser_params.except(:flyer))
      redirect_to fundraiser_path(@fundraiser), notice: 'Fundraiser updated successfully.'
    else
      @programs = @school.programs.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fundraiser.destroy
    redirect_to fundraisers_path, notice: 'Fundraiser removed.'
  end

  private

  def set_fundraiser
    @fundraiser = Fundraiser.find(params[:id])
  end

  def fundraiser_params
    params.require(:fundraiser).permit(
      :title, :description, :goal, :call_to_action,
      :start_date, :end_date, :program_id, :flyer
    )
  end

  def require_feature_enabled!
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false unless @school&.fundraisers_enabled?
  end
end
