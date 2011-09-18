  Factory.define :order do |o|
    o.user {User.first}
    o.amount 100
  end

  Factory.define :pending, :class => Order do |o|
    o.description "pending order"
    o.user {User.first}
    o.amount 100
    o.state 'pending'
  end

  Factory.define :authorized, :class => Order do |o|
    o.description 'authorized order'
    o.user {User.first}
    o.amount 100
    o.state 'authorized'
  end

  Factory.define :uncapturable, :class => Order do |o|
    o.user {User.first}
    o.description 'authorized, but uncapturable'
    o.amount 100
    o.state 'authorized'
  end

  Factory.define :uncapturable_error, :class => Order  do |o|
    o.user {User.first}
    o.description 'authorized, but uncapturable due to error'
    o.amount 100
    o.state 'authorized'
  end

  Factory.define :subscription_test, :class => Order  do |o|
    o.user {User.first}
    o.description 'this is an order for a subscription'
    o.amount '1300'
    o.state 'authorized'
  end