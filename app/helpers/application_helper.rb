module ApplicationHelper
  # 123450 -> "$1,234.50"
  def money(cents)
    number_to_currency(cents.to_d / 100)
  end

  # 2026-10-03 -> "Oct 3, 2026"
  def short_date(date)
    date.strftime("%b %-d, %Y")
  end

  def status_badge(status)
    tag.span(status, class: "badge badge-#{status}")
  end
end
