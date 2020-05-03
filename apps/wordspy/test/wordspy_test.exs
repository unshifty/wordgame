defmodule WordspyTest do
  use ExUnit.Case
  doctest Wordspy

  test "greets the world" do
    assert Wordspy.hello() == :world
  end
end
