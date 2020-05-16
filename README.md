# APIs for mobile alongside traditional web application with HTML views

## Background

The purpose of this project is to document and explore an approach to mobile authentication in Rails applications, that supports both a conventional server-rendered Rails web frontend and a native mobile application frontend.

This project was created to support this discussion in the Ruby on Rails Discussion forum: [APIs for mobile alongside traditional web application with HTML views](https://discuss.rubyonrails.org/t/apis-for-mobile-alongside-traditional-web-application-with-html-views/75089).

## Project Setup

This project is a Rails 5.2 project created with the following command:

`rails new --force --database=postgresql rails_web_and_mobile`

I choose Rails 5.2 since that is the version that I got this approach working in, and I'm trying to avoid any surprises.