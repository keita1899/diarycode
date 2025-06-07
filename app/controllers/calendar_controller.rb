class CalendarController < ApplicationController
  before_action :authenticate_user!

  def index
    @today = Date.current
    @current_month = if params[:month].present?
                       begin
                         Date.parse(params[:month]).beginning_of_month
                       rescue Date::Error
                         @today.beginning_of_month
                       end
                     else
                       @today.beginning_of_month
                     end
    @calendar_days = build_calendar_days(@current_month)

    # 現在表示している月の日報データを取得（日付をキーとしたハッシュ）
    @reports = current_user.reports.
                 where(date: @calendar_days.first..@calendar_days.last).
                 index_by(&:date)
  end

  private

    def build_calendar_days(month)
      start_date = month.beginning_of_month
      end_date = month.end_of_month

      calendar_start = start_date.beginning_of_week(:monday)
      calendar_end = end_date.end_of_week(:monday)

      (calendar_start..calendar_end).to_a
    end
end
