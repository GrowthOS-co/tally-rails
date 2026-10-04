require "test_helper"

class DashboardTest < ActiveSupport::TestCase
  setup do
    @customer = Customer.create!(name: "Maya Ortiz", email: "maya@example.com")
  end

  test "totals outstanding, overdue and paid this month" do
    sent_overdue = create_invoice(due_date: "2026-03-10", items: [ [ "Consulting", 1, 10000 ] ])
    sent_overdue.mark_sent!

    create_invoice(due_date: "2026-04-01", items: [ [ "Design", 2, 5000 ] ]).mark_sent!

    paid_this_month = create_invoice(items: [ [ "Audit", 1, 30000 ] ])
    paid_this_month.mark_sent!
    paid_this_month.mark_paid!(on: Date.new(2026, 3, 2))

    paid_last_month = create_invoice(items: [ [ "Setup", 1, 70000 ] ])
    paid_last_month.mark_sent!
    paid_last_month.mark_paid!(on: Date.new(2026, 2, 27))

    create_invoice(items: [ [ "Draft work", 1, 99900 ] ])

    dashboard = Dashboard.new(today: Date.new(2026, 3, 15))
    assert_equal 20000, dashboard.outstanding_cents
    assert_equal 1, dashboard.overdue_invoices.size
    assert_equal 10000, dashboard.overdue_cents
    assert_equal 30000, dashboard.paid_this_month_cents
    assert_equal [ sent_overdue ], dashboard.overdue_invoices
  end

  private
    def create_invoice(items:, due_date: "2026-03-03")
      Invoice.create!(
        customer: @customer,
        issue_date: "2026-02-01",
        due_date:,
        line_items_attributes: items.map do |description, quantity, unit_price_cents|
          { description:, quantity:, unit_price_cents: }
        end
      )
    end
end
