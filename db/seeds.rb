# Replaces everything in the database with the sample business below. Dates
# are relative to today, so the dashboard always has overdue invoices and
# payments this month. Run with `bin/rails db:seed`.

customers = [
  { name: "Maya Ortiz", email: "maya@harborandpine.example", company: "Harbor & Pine Interiors" },
  { name: "Daniel Kim", email: "daniel@kimphoto.example", company: "Kim Photography" },
  { name: "Priya Raman", email: "priya.raman@example.com", company: nil },
  { name: "Lucas Weber", email: "lucas@northfieldbikes.example", company: "Northfield Bikes" },
  { name: "Aisha Bello", email: "aisha@bellocatering.example", company: "Bello Catering" },
  { name: "Tom Gallagher", email: "tom.gallagher@example.com", company: nil },
  { name: "Sofia Marques", email: "sofia@lumenstudio.example", company: "Lumen Studio" },
  { name: "Ethan Brooks", email: "ethan@brooksandco.example", company: "Brooks & Co. Accounting" }
]

# customer is an index into customers; items are [description, quantity, unit price in cents].
invoices = [
  { customer: 0, issued_days_ago: 95, term_days: 30, status: "paid", paid_days_ago: 70, items: [ [ "Interior design consultation (hours)", 4, 15000 ], [ "Mood boards", 2, 7500 ] ] },
  { customer: 1, issued_days_ago: 80, term_days: 30, status: "paid", paid_days_ago: 52, items: [ [ "Product photography, half day", 1, 60000 ], [ "Image retouching", 25, 1200 ] ] },
  { customer: 3, issued_days_ago: 60, term_days: 30, status: "paid", paid_days_ago: 33, items: [ [ "Website maintenance, monthly", 1, 25000 ] ] },
  { customer: 4, issued_days_ago: 40, term_days: 30, status: "paid", paid_days_ago: 2, items: [ [ "Event menu planning", 1, 40000 ], [ "Tasting session", 2, 9500 ] ] },
  { customer: 6, issued_days_ago: 35, term_days: 30, status: "paid", paid_days_ago: 1, items: [ [ "Brand identity package", 1, 180000 ] ] },
  { customer: 7, issued_days_ago: 30, term_days: 30, status: "paid", paid_days_ago: 0, notes: "Thank you for your prompt payment.", items: [ [ "Bookkeeping, monthly", 1, 45000 ] ] },
  { customer: 0, issued_days_ago: 50, term_days: 30, status: "sent", notes: "Net 30.", items: [ [ "Furniture sourcing (hours)", 6, 8000 ] ] },
  { customer: 2, issued_days_ago: 45, term_days: 30, status: "sent", items: [ [ "Copywriting, per page", 5, 12000 ] ] },
  { customer: 5, issued_days_ago: 38, term_days: 30, status: "sent", items: [ [ "Garden design consultation (hours)", 3, 9000 ], [ "Site visit", 1, 6000 ] ] },
  { customer: 3, issued_days_ago: 33, term_days: 30, status: "sent", items: [ [ "Website maintenance, monthly", 1, 25000 ], [ "Hosting renewal", 1, 12000 ] ] },
  { customer: 1, issued_days_ago: 20, term_days: 30, status: "sent", items: [ [ "Headshot session", 8, 9500 ] ] },
  { customer: 4, issued_days_ago: 15, term_days: 30, status: "sent", notes: "Net 30.", items: [ [ "Corporate lunch catering, per guest", 40, 2200 ] ] },
  { customer: 6, issued_days_ago: 12, term_days: 30, status: "sent", items: [ [ "Social media templates", 10, 4500 ] ] },
  { customer: 7, issued_days_ago: 10, term_days: 30, status: "sent", items: [ [ "Quarterly tax filing", 1, 75000 ] ] },
  { customer: 5, issued_days_ago: 7, term_days: 30, status: "sent", items: [ [ "Planting plan", 1, 30000 ] ] },
  { customer: 0, issued_days_ago: 5, term_days: 30, status: "sent", items: [ [ "Lighting plan", 1, 52000 ] ] },
  { customer: 2, issued_days_ago: 3, term_days: 30, status: "draft", items: [ [ "Blog posts", 4, 15000 ] ] },
  { customer: 3, issued_days_ago: 2, term_days: 30, status: "draft", items: [ [ "Bike fleet servicing, per bike", 12, 6500 ] ] },
  { customer: 4, issued_days_ago: 1, term_days: 30, status: "draft", notes: "50% deposit.", items: [ [ "Wedding catering deposit", 1, 150000 ] ] },
  { customer: 6, issued_days_ago: 0, term_days: 30, status: "draft", items: [ [ "Packaging design", 1, 95000 ], [ "Print-ready files", 3, 5000 ] ] }
]

today = Date.current

# A payment made "this month" stays in this month even on the 1st.
paid_date = lambda do |days_ago|
  date = today - days_ago
  days_ago <= 2 && date < today.beginning_of_month ? today.beginning_of_month : date
end

ActiveRecord::Base.transaction do
  LineItem.delete_all
  Invoice.delete_all
  Customer.delete_all
  ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence")

  records = customers.map { |attributes| Customer.create!(attributes) }

  invoices.each do |sample|
    issue_date = today - sample[:issued_days_ago]
    Invoice.create!(
      customer: records[sample[:customer]],
      issue_date:,
      due_date: issue_date + sample[:term_days],
      status: sample[:status],
      paid_date: sample[:paid_days_ago] && paid_date.call(sample[:paid_days_ago]),
      notes: sample[:notes],
      line_items_attributes: sample[:items].map do |description, quantity, unit_price_cents|
        { description:, quantity:, unit_price_cents: }
      end
    )
  end
end

puts "Seeded #{customers.size} customers and #{invoices.size} invoices."
