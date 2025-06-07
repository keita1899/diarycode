class ReportsController < ApplicationController
  before_action :authenticate_user!

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

  private

    def report_params
      params.require(:report).permit(:date, :body)
    end
end
