module ReportsHelper
  def github_push_status_label(report)
    case report.github_push_status
    when "pushed"
      "✅ プッシュ済み"
    when "failed"
      "❌ プッシュ失敗"
    else
      "⚪ 未プッシュ"
    end
  end
end
