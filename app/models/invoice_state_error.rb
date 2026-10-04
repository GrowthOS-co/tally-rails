# Raised when an invoice is asked to do something its status does not allow,
# such as editing an invoice that has already been sent.
class InvoiceStateError < StandardError
  def initialize(invoice, action)
    super("Invoice #{invoice.number} is #{invoice.status} and cannot be #{action}.")
  end
end
