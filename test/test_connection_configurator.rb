require "test_helper"

class TestConnectionConfigurator < Test::Unit::TestCase
  def setup
    ExceptionsBegone::ConnectionConfigurator.global_connection= nil
  end

  def test_port_should_be_set
    conn_conf = ExceptionsBegone::ConnectionConfigurator.build
    assert_equal 80, conn_conf.port
  end

  def test_should_work_with_right_init
    ExceptionsBegone::ConnectionConfigurator.global_connection= nil

    conn_conf = ExceptionsBegone::ConnectionConfigurator.new({ :project => "test_project",
                                                                :open_timeout => 5,
                                                                :read_timeout => 5,
                                                                :servers => [ { :host => "localhost",
                                                                                :port => 7070 },
                                                                              { :host => "localhost",
                                                                                :port => 7071 }]})

    assert conn_conf.servers.size, 2
  end

  def test_should_work_with_right_init_but_no_server
    ExceptionsBegone::ConnectionConfigurator.global_connection= nil

    conn_conf = ExceptionsBegone::ConnectionConfigurator.new( :project => "test_project",
                                                              :open_timeout => 5,
                                                              :read_timeout => 5)

    assert conn_conf.servers.size, 1
  end
end
