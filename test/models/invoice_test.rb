require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  TODAY = Date.new(2026, 3, 15)

  test "total adds up quantity times unit price over every line item" do
    invoice = Invoice.new(line_items: [
      LineItem.new(quantity: 3, unit_price_cents: 1250),
      LineItem.new(quantity: 1, unit_price_cents: 9999)
    ])

    assert_equal 13749, invoice.total_cents
  end

  test "is overdue only when sent and the due date has passed" do
    assert Invoice.new(status: :sent, due_date: Date.new(2026, 3, 14)).overdue?(TODAY)
    assert_not Invoice.new(status: :sent, due_date: Date.new(2026, 3, 15)).overdue?(TODAY)
    assert_not Invoice.new(status: :paid, due_date: Date.new(2026, 3, 1)).overdue?(TODAY)
    assert_not Invoice.new(status: :draft, due_date: Date.new(2026, 3, 1)).overdue?(TODAY)
  end

  test "editing an invoice that has been sent raises and changes nothing" do
    customer = Customer.create!(name: "Maya Ortiz", email: "maya@example.com")
    invoice = Invoice.create!(customer:, issue_date: "2026-02-01", due_date: "2026-03-03",
                              line_items_attributes: [ { description: "Consulting", quantity: 1, unit_price_cents: 10000 } ])
    invoice.mark_sent!

    assert_raises(InvoiceStateError) do
      invoice.revise(line_items_attributes: [ { description: "Changed", quantity: 5, unit_price: "0.01" } ])
    end
    assert_equal [ "Consulting" ], invoice.reload.line_items.map(&:description)
  end
end
