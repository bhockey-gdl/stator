# Stator

Stator is a minimalist's state machine. It's a simple dsl that uses existing ActiveRecord functionality to accomplish common state machine funcitonality. This is not a full-featured computer-science driven gem, it's a gem that covers the 98% of use cases.

```ruby
gem 'stator', git: 'git@github.com:mnelson/stator.git', tag: '0.0.1'
```

## Usage

If you've used the state_machine it's a pretty similar dsl. You define your state machine with it's initial state, you define your transitions, and you define your callbacks (if any).

```ruby
  class User < ActiveRecord::Base
    extend Stator::Model

    stator :unactivated do

      transition :semiactivate do
        from :unactivated
        to   :semiactivated
      end

      transition :activate do
        from :unactivated, :semiactivated
        to   :activated
      end

      transition :deactivate do
        from any
        to   :deactivate
      end

    end
  end
```

Then you use like this:

```ruby
u = User.new
u.state
# => 'unactivated'
u.persisted?
# => false
u.semiactivate
# => true
u.state
# => 'semiactivated'
u.persisted?
# => true
```

## Advanced Usage

The intention of stator was to avoid hijacking ActiveRecord or reinvent the wheel. You can conditionally validate, invoke callbacks, etc. via a with_options-like invocation - no magic:

```ruby
class User < ActiveRecord::Base
  extend Stator::Model

  stator :unactivated, field: :status do

    transition :activate do
      from :unactivated
      to   :activated

      # wo is an ActiveSupport::OptionMerger with a `if` condition set which will ensure the state 
      # was one of the `from` states and is one of the `to` states.
      conditional do |wo|
        wo.validate :validate_user_ip_not_blacklisted
      end

    end

    # wo is an ActiveSupport::OptionMerger with a `if` condition already set which will ensure the state 
    # is one of the ones provided to the `#conditional` invocation.
    conditional :activated, :semiactivated do |wo|
      wo.validates :email, presence: true
    end

  end
end
```

If you need to access the state machine directly, you can do so via the class:

```ruby
User._stator
```