# APIs for mobile alongside traditional web application with HTML views

## Background

The purpose of this project is to document and explore an approach to mobile authentication in Rails applications, that supports both a conventional server-rendered Rails web frontend and a native mobile application frontend.

This project was created to support this discussion in the Ruby on Rails Discussion forum: [APIs for mobile alongside traditional web application with HTML views](https://discuss.rubyonrails.org/t/apis-for-mobile-alongside-traditional-web-application-with-html-views/75089).

## Project Setup

This project is a Rails 5.2 project created with the following command:

`rails new --force --database=postgresql rails_web_and_mobile`

I choose Rails 5.2 since that is the version that I got this approach working in, and I'm trying to avoid any surprises.

## Project Development

This section will outline the steps taken to get from a bare rails project to one that support authentication for a server rendered web frontend alongside token based authentication for a native mobile app. I made each major change on a separate branch and then merged the branch into master. I also attempted to keep each change needed to make progress isolated in a single commit.

The project uses [scaffolding](https://guides.rubyonrails.org/command_line.html#rails-generate).

The basic idea for this project is that we are building a system for a small Corner Shop where Customers can submit Orders which will be viewed and fulfilled by Shopkeepers.

### Adding Orders

All the plumbing for Orders were generated using scaffolding:

1. Create Orders using scaffold: 

    `rails generate scaffold Order item:string quantity:integer status:string`

2. Create database:

    `rails db:create`

3. Run migrations

    `rails db:migrate`

4. Added dropdown list for Order `status`. Status is implemented as an [enum](https://api.rubyonrails.org/v5.2.3/classes/ActiveRecord/Enum.html) with [string values](https://sipsandbits.com/2018/04/30/using-database-native-enums-with-rails/) and dropdown list is populated using the [enum attriubutes](https://stackoverflow.com/a/23686698).

### Adding Pages

Added some placeholder pages for Home and About.

1. `rails g controller Pages home about`

2. Set application root to the Home page

### Add Devise Authentication

Devise is used for authentication and was setup as follows:

1. Add Devise gem to the Gemfile and install as documented in the [Getting Started Guide](https://github.com/heartcombo/devise#getting-started). The only change is that I specified the version of Devise in the Gemfile.

### Add Customer

1. Add Devise Customer model

    `rails generate devise Customer`

