# Ruby Terminal Vending Machine

## Initial request

Design a Vending Machine in code:


      The Vending Machine, once a Product is selected and the appropriate amount of money is inserted, should return that Product. 
      It should also ask for more money if there is not enough or return change if too much money is provided.
      Change should be printed as Coin * quantity and it should return as much as possible Coins with the minimum amount.
      Keep in mind that you need to manage the scenario where the selected Product is out of stock or the machine does not have enough change to return to the customer.

      Available Coins:

         - 0.25$;
         - 0.5$; 
         - 1$;
         - 2$;
         - 3$;
         - 5$;

## Installation

1. Download `ruby_vending_machine` ruby gem to your machine:

        https://github.com/azelenets/terminal_vending_machine

2. Customize `Products` and `Coins` changing content in the `lib/data/*.json` files.

3. Setup application:

        $ bin/setup

## Usage

Execute inside application directory in terminal 

    $ ruby exe/ruby_vending_machine

## Tests

Project covered with specs using RSpec. To run tests use `bundle exec rspec` command.

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruby_vending_machine. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ruby_vending_machine/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubyVendingMachine project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruby_vending_machine/blob/master/CODE_OF_CONDUCT.md).
