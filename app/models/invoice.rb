class Invoice < ApplicationRecord
  # What a list can filter by: overdue is not stored, it is a sent invoice past
  # its due date.
  DISPLAY_STATUSES = %w[draft sent overdue paid].freeze

  belongs_to :customer
  has_many :line_items, -> { order(:id) }, inverse_of: :invoice

  accepts_nested_attributes_for :line_items

  enum :status, { draft: "draft", sent: "sent", paid: "paid" }, default: :draft

  normalizes :notes, with: ->(value) { value.strip.presence }

  validates :issue_date, :due_date, presence: true
  validate :must_have_line_items

  before_create :assign_number
  before_destroy :ensure_draft_for_delete

  scope :overdue, ->(today = Date.current) { sent.where(due_date: ...today) }

  def self.with_display_status(status, today = Date.current)
    case status
    when "overdue" then overdue(today)
    when "sent" then sent.where(due_date: today..)
    when "draft", "paid" then where(status:)
    else all
    end
  end

  def total_cents
    line_items.to_a.sum(&:amount_cents)
  end

  def overdue?(today = Date.current)
    sent? && due_date < today
  end

  def display_status(today = Date.current)
    overdue?(today) ? "overdue" : status
  end

  # Only a draft can change: once sent, the customer has a copy. The line items
  # in the attributes replace the current ones as a whole.
  def revise(attributes)
    raise InvoiceStateError.new(self, "edited") unless draft?

    line_items.each(&:mark_for_destruction)
    update(attributes)
  end

  def mark_sent!
    raise InvoiceStateError.new(self, "sent") unless draft?

    sent!
  end

  def mark_paid!(on: Date.current)
    raise InvoiceStateError.new(self, "marked as paid") unless sent?

    update!(status: :paid, paid_date: on)
  end

  private
    def must_have_line_items
      if line_items.reject(&:marked_for_destruction?).empty?
        errors.add(:base, "An invoice needs at least one line item.")
      end
    end

    def assign_number
      self.number = format("INV-%04d", (Invoice.maximum(:id) || 0) + 1)
    end

    def ensure_draft_for_delete
      raise InvoiceStateError.new(self, "deleted") unless draft?
    end
end
