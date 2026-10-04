# Tally

Invoicing for small businesses: keep a list of customers, write invoices with
line items, send them, mark them paid, and see what is outstanding and overdue
on the dashboard.

Built with Ruby on Rails, Active Record on SQLite, ERB views, and Stimulus for
the invoice form's line item rows.

## Getting started

```bash
bundle install
bin/rails db:prepare   # creates storage/development.sqlite3, migrates, loads sample data
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000).

`bin/rails db:seed` can be run at any time: it replaces everything in the
database with the sample business.

## How it works

- **Customers** have a name, an email and an optional company.
- **Invoices** belong to a customer, have an issue date, a due date, notes and
  one or more line items (description, quantity, unit price). Money is stored
  as whole cents.
- An invoice is `draft`, `sent` or `paid`. Only a draft can be edited or
  deleted; asking anything else of an invoice raises `InvoiceStateError`. A
  sent invoice whose due date has passed shows as **overdue**; that is worked
  out when it is shown, never stored.
- The **dashboard** shows the total outstanding (all sent invoices), what is
  overdue, and what was paid this month.

| Path                                   | What it is                                   |
| -------------------------------------- | -------------------------------------------- |
| `db/migrate/`, `db/schema.rb`          | the tables                                   |
| `db/seeds.rb`                          | the sample business                          |
| `app/models/`                          | invoice, customer and dashboard logic        |
| `app/controllers/`, `app/views/`       | pages and form actions                       |
| `app/javascript/controllers/`          | adding and removing line item rows           |
| `app/assets/stylesheets/application.css` | the styles                                 |
| `test/models/`                         | the tests                                    |

## Changing the database

```bash
bin/rails generate migration AddSomethingToInvoices
bin/rails db:migrate   # applies it and updates db/schema.rb
```

## Tests

```bash
bin/rails test
```
