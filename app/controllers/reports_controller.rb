class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [:edit, :update, :destroy]

  def new
    @report = current_user.reports.build
    @report.date = if params[:date].present?
                     begin
                       Date.parse(params[:date])
                     rescue Date::Error
                       Date.current
                     end
                   else
                     Date.current
                   end
  end

  def create
    @report = current_user.reports.build(report_params)

    if @report.save
      redirect_to calendar_path, notice: t("flash.reports.create.notice")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @report.update(report_params)
      redirect_to calendar_path, notice: t("flash.reports.update.notice")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy!
    redirect_to calendar_path, notice: t("flash.reports.destroy.notice")
  end

  private

    def set_report
      @report = current_user.reports.find(params[:id])
    end

    def report_params
      params.require(:report).permit(:date, :body)
    end
end
