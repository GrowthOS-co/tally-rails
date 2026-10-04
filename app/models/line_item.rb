class LineItem < ApplicationRecord
  # A non-negative amount in dollars with at most two decimals, e.g. "120.50".
  DOLLARS = /\A(\d+)(?:\.(\d{1,2}))?\z/

  belongs_to :invoice

  validates :description, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :unit_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "must be an amount like 120.50" }

  normalizes :description, with: ->(value) { value.strip }

  def amount_cents
    quantity * unit_price_cents
  end

  # The unit price as typed in the form, in dollars.
  def unit_price
    @unit_price || (unit_price_cents && format("%d.%02d", *unit_price_cents.divmod(100)))
  end

  def unit_price=(dollars)
    @unit_price = dollars.strip
    match = DOLLARS.match(@unit_price)
    self.unit_price_cents = match && (match[1].to_i * 100 + match[2].to_s.ljust(2, "0").to_i)
  end
end
