class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: [:edit, :update, :destroy]

  def new
    @report = Report.build_for_user(current_user, date_param: params[:date])
  end

  def create
    @report = current_user.reports.build(report_params)

    if @report.save
      handle_post_save_action(:create)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @report.update(report_params)
      handle_post_save_action(:update)
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

    def handle_post_save_action(action_type)
      if @report.should_push_to_github?(params.dig(:report, :push_to_github))
        flash_data = @report.push_to_github_with_messages(action_type)
        redirect_to calendar_path, flash_data[:type] => flash_data[:message]
      else
        notice_key = (action_type == :create) ? "flash.reports.create.notice" : "flash.reports.update.notice"
        redirect_to calendar_path, notice: t(notice_key)
      end
    end
end
