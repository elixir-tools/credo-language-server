defmodule UnlessWithElse do
  def foo() do
    unless 1 == 2 do
      :hello
    else
      :world
    end
  end
end
