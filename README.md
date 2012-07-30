# PLEASE NOTE

masquerade is the predecessor of [masq](https://github.com/dennisreimann/masq) - please consider using masq from now on, as it is the more modular approach.



# masquerade OpenID Server

masquerade is an OpenID server released under the MIT-license.

For updates and further information see the [project website](http://github.com/dennisreimann/masquerade/).

The source code is available at [github](http://github.com/dennisreimann/masquerade/) - feel free to fork and submit patches :)

## Installation

1. Setup your bundle:
    * run `bundle install`

2. Configure the database:
    * rename the file `config/database.yml.example` to `config/database.yml`
    * set the values in `database.yml` according to your database
    * run the migration scripts
        - `bundle exec rake db:create`
        - `bundle exec rake db:migrate`

3. Configure the application:
    * rename the file `config/app_config.yml.example` to `app_config.yml`
    * set the values in `app_config.yml` according to your environment

4. Run the tests and see if everything seems to work
	`bundle exec rake test`

## Testing the installation

You can test the functionality in your local environment starting two instances: One as
your Identity Provider/OpenID Server and another one as Relying Party.

	ruby script/server
	ruby script/server -p 3001

Open your browser with these urls:

* [http://localhost:3000](http://localhost:3000) (Identity Provider)
* [http://localhost:3001/consumer](http://localhost:3001/consumer) (Relying Party testsuite)

First you have to create an account at the Identity Provider, after that you will be able
to use the issued OpenID URL (`http://localhost:3000/YOUR_LOGIN`) to send requests from the
Relying Party to the server.

Use the options provided by the OpenID verification form to test several aspects of the
client-server communication (like requesting simple registration data).

## Introduction

The main functionality is in the server controller, which is the endpoint for incoming
OpenID requests. The server controller is supposed to only interact with relying parties
a.k.a. consumer websites. It includes the OpenidServerSystem module, which provides some
handy methods to access and answer OpenID requests.

## TODO

* Let the user set a standard persona which is used as default for requests

## Notes

Inspiration derived from:

* The [ruby-openid gem](https://github.com/openid/ruby-openid/) server example
* James Y Stewart: [A Ruby on Rails OpenID Server](http://jystewart.net/process/2007/10/a-ruby-on-rails-openid-server/)

## Contact

[Dennis Reimann](mailto:mail@dennisreimann.de)
