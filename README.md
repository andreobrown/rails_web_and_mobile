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

2. Redirect Customer to Orders page after login

3. Add Login and Logout links

4. Require that Customer be signed in to access Orders

### Associate Orders to Customers

1. Generate migration to create association

    `rails generate migration AddCustomerReferenceToOrders customer:belongs_to`

2. Run the migration

    `rails db:migrate`

3. Restrict Customers to their Orders

   Only return Customer's orders when listing and searching.
   Associate Orders to Customers on creation (using `current_customer`).
   
### Add Token Authentication

This section [follows this guide](https://medium.com/@brentkearney/json-web-token-jwt-and-html-logins-with-devise-and-ruby-on-rails-5-9d5e8195193d).

1. Add [`devise-jwt`](https://github.com/waiting-for-dev/devise-jwt) gem

2. Configure Devise and Warden for JWT

    A few things that I don't understand here:

    * What exactly do these changes do and why are they needed?

    * skip_session_storage - what's the purpose of setting this?

    * config.navigational_formats - why does this need to be set? 

3. Configure routes for API login and logout

    Questions:

    * Why is the following code needed inside the api route:

        ```
        devise_scope :customer do
            get "login", to: "customers/sessions#new"
            delete "logout", to: "customers/sessions#destroy"
        end
        ```

4. Update the Customer table to add field for jti

   We are using the [JTIMatcher recovation strategy](https://github.com/waiting-for-dev/devise-jwt#revocation-strategies)

   I had to uncomment `class_name: "ApiCustomer",` in `routes.rb` to get this to run, since the model hasn't been setup yet.
   
   Update the Customer table using the following migration:

   `rails generate migration AddJTIToCustomers`

   ```
   #db/migrate/20200517053419_add_jti_to_customers.rb
   class AddJtiToCustomers < ActiveRecord::Migration[5.2]
    def change
        add_column :customers, :jti, :string
        # populate jti so we can make it not nullable
        Customer.all.each do |customer|
        customer.update_column(:jti, SecureRandom.uuid)
        end
        change_column_null :customers, :jti, false
        add_index :customers, :jti, unique: true
    end
    end
    ```

    `rails db:migrate`

5. Update the Customer model to ensure that the jti column is filled out at time of Customer creation

    ```
    before_create :add_jti

    def add_jti
        self.jti ||= SecureRandom.uuid
    end
    ```

6. Add an ApiCustomer model, as a sub-class of Customer

    ```
    class ApiCustomer < Customer
        include Devise::JWT::RevocationStrategies::JTIMatcher
        devise :jwt_authenticatable, jwt_revocation_strategy: self
        validates :jti, presence: true

        def generate_jwt
            JWT.encode({ id: id,
                        exp: 1.day.from_now.to_i },
                    Rails.env.devise.jwt.secret_key)
        end
    end
    ```

    Question: why couldn't this have been in the regular Customer model?

7. Configure json requests to use `api_customer` scope for authentication.

    ```
    # Disable CSRF protection for json calls
    protect_from_forgery with: :exception, unless: :json_request?
    protect_from_forgery with: :null_session, if: :json_request?
    skip_before_action :verify_authenticity_token, if: :json_request?
    rescue_from ActionController::InvalidAuthenticityToken,
                with: :invalid_auth_token
    # Set the current customer so that Devise and other gems that use `current_customer` can work.
    before_action :set_current_customer, if: :json_request?

    private
    def json_request?
        request.format.json?
    end
    # Use api_customer Devise scope for JSON access
    def authenticate_customer!(*args)
        super and return unless args.blank?
        json_request? ? authenticate_api_customer! : super
    end

    def invalid_auth_token
        respond_to do |format|
        format.html { redirect_to sign_in_path, 
                        error: 'Login invalid or expired' }
        format.json { head 401 }
        end
    end

    # So we can use Pundit policies for api_customers
    def set_current_customer
        @current_customer ||= warden.authenticate(scope: :api_customer)
    end
    ```

    Is this all so that we can have a different set of behaviours for API users (vs. browser users)?

8. Override API SessionsController

    This controller responds with json by default, signs in the user and returns the jwt token. I'm guessing that this sign in process is what allows the token to be used transparently and what allows `current_customer` to be set so other controllers just work?

    ```
    class Api::SessionsController < Devise::SessionsController
        # I'm guessing this isn't required since we don't track signed in/signed out status for the API user?
        skip_before_action :verify_signed_out_user
        # This sets the default response format to json instead of html
        respond_to :json
        # POST /api/login
        def create
            unless request.format == :json
            sign_out # why is this needed?
            render status: 406,
                    json: { message: "JSON requests only." } and return
            end
            # auth_options should have `scope: :api_customer`
            resource = warden.authenticate!(auth_options)
            if resource.blank?
            render status: 401,
                    json: { response: "Access denied." } and return
            end
            sign_in(resource_name, resource)
            respond_with resource, location: after_sign_in_path_for(resource) do |format|
            format.json {
                render json: { success: true,
                            jwt: current_token,
                            response: "Authentication successful" }
            }
            end
        end

        private

        def current_token
            request.env["warden-jwt_auth.token"]
        end
    end
    ```
9. Add “new” view in json format

   If this file isn't added, the follow error is generated when attempting to login:

   ```
   undefined method `api_customers_url' for #<Api::SessionsController:0x00007fb9ded22298> Did you mean? api_customer_session_url

   actionpack (5.2.4.2) lib/action_dispatch/routing/polymorphic_routes.rb:232:in `polymorphic_method'
   ```

10. Add jwt_key_base to credentials file
    
    Generate the key with `rake secret`

    Run `rails credentials:edit`

    Add the generated key as `jwt_key_base`.