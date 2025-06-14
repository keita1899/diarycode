module CalendarHelper
  def calendar_today?(date, today)
    date == today
  end

  def calendar_sunday?(date)
    date.wday == 0
  end

  def calendar_saturday?(date)
    date.wday == 6
  end

  def calendar_current_month?(date, current_month)
    date.month == current_month.month
  end

  def calendar_date_class(date, today, current_month)
    return "bg-blue-600 text-white px-2 py-1 rounded-full" if calendar_today?(date, today)

    if calendar_current_month?(date, current_month)
      if calendar_sunday?(date)
        "text-red-600"
      elsif calendar_saturday?(date)
        "text-blue-600"
      else
        "text-gray-900"
      end
    else
      "text-gray-400"
    end
  end

  def calendar_github_status_dot(report)
    return unless report

    if report.github_pushed?
      status_dot("blue", "GitHubにプッシュ済み")
    elsif report.github_push_failed?
      status_dot("red", "GitHubプッシュ失敗")
    end
  end

  def status_dot(color, title)
    css_class = case color
                when "blue"
                  "w-2 h-2 bg-blue-500 rounded-full"
                when "red"
                  "w-2 h-2 bg-red-500 rounded-full"
                end

    content_tag(:div, "", class: css_class, title: title)
  end
end
