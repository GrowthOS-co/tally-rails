class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show edit update destroy mark_sent mark_paid]

  # A page opened before the invoice changed status can still post an action
  # the invoice no longer allows.
  rescue_from InvoiceStateError do |error|
    redirect_to @invoice, alert: error.message
  end

  def index
    @status = params[:status].presence_in(Invoice::DISPLAY_STATUSES)
    @invoices = Invoice.with_display_status(@status).includes(:customer, :line_items).order(issue_date: :desc)
  end

  def show
  end

  def new
    today = Date.current
    @invoice = Invoice.new(customer_id: params[:customerId], issue_date: today, due_date: today + 30)
    @invoice.line_items.build(quantity: 1)
  end

  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
      redirect_to @invoice
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @invoice.revise(invoice_params)
      redirect_to @invoice
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy!
    redirect_to invoices_path, status: :see_other
  end

  def mark_sent
    @invoice.mark_sent!
    redirect_to @invoice
  end

  def mark_paid
    @invoice.mark_paid!
    redirect_to @invoice
  end

  private
    def set_invoice
      @invoice = Invoice.find(params.expect(:id))
    end

    def invoice_params
      params.expect(invoice: [ :customer_id, :issue_date, :due_date, :notes,
                               line_items_attributes: [ [ :description, :quantity, :unit_price ] ] ])
    end
end
