class CustomersController < ApplicationController
  before_action :set_customer, only: %i[show edit update]

  def index
    @customers = Customer.order(:name)
  end

  def show
    @invoices = @customer.invoices.includes(:line_items).order(issue_date: :desc)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      redirect_to @customer
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_customer
      @customer = Customer.find(params.expect(:id))
    end

    def customer_params
      params.expect(customer: [ :name, :email, :company ])
    end
end
