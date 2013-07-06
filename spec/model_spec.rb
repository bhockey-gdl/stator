require 'spec_helper'

describe Stator::Model do

  it 'should provide access to the state machine' do
    User._stator.should_not be_nil
  end

  it 'should set the default state after initialization' do
    u = User.new
    u.state.should eql('pending')
  end

  it 'should see the initial setting of the state as a change with the initial state as the previous value' do
    u = User.new
    u.state = 'activated'
    u.state_was.should eql('pending')
  end

  it 'should not obstruct normal validations' do
    u = User.new
    u.should_not be_valid
    u.errors[:email].grep(/length/).should_not be_empty
  end

  it 'should ensure a valid state transition when given a bogus state' do
    u = User.new
    u.state = 'anythingelse'

    u.should_not be_valid
    u.errors[:state].should_not be_empty
  end

  it 'should ensure a valid state transition when given an illegal state based on the current state' do
    u = User.new
    u.state = 'hyperactivated'

    u.should_not be_valid
    u.errors[:state].should_not be_empty

  end

  it 'should run conditional validations' do
    u = User.new
    u.state = 'semiactivated'
    u.should_not be_valid

    u.errors[:state].should be_empty
    u.errors[:email].grep(/format/).should_not be_empty
  end

  it 'should invoke callbacks' do
    u = User.new(:activated => true, :email => 'doug@example.com', :name => 'doug')
    u.activated.should == true

    u.deactivate

    u.activated.should == false
    u.state.should eql('deactivated')
    u.should be_persisted
  end

  it 'should blow up if the record is invalid and a bang method is used' do
    u = User.new(:email => 'doug@other.com', :name => 'doug')
    lambda{
      u.activate!
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should allow for other fields to be used other than state' do
    a = Animal.new
    a.should be_valid

    a.birth!
  end

end