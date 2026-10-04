class Customer < ApplicationRecord
  has_many :invoices

  normalizes :name, :email, with: ->(value) { value.strip }
  normalizes :company, with: ->(value) { value.strip.presence }

  validates :name, :email, presence: true
end
