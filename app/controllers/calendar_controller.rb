class CalendarController < ApplicationController
  before_action :authenticate_user!

  def index
    @today = Date.current
    @current_month = params[:month] ? Date.parse(params[:month]) : @today.beginning_of_month
    @calendar_days = build_calendar_days(@current_month)
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
