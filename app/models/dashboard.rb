# The numbers on the dashboard: what is outstanding, what is overdue and what
# was paid this month, as of today.
class Dashboard
  attr_reader :today

  def initialize(today: Date.current)
    @today = today
  end

  def outstanding_cents
    total(Invoice.sent)
  end

  # Oldest due date first.
  def overdue_invoices
    @overdue_invoices ||= Invoice.overdue(today).includes(:customer, :line_items).order(:due_date).to_a
  end

  def overdue_cents
    overdue_invoices.sum(&:total_cents)
  end

  def paid_this_month_cents
    total(Invoice.paid.where(paid_date: today.beginning_of_month..today))
  end

  private
    def total(invoices)
      invoices.includes(:line_items).sum(&:total_cents)
    end
end
