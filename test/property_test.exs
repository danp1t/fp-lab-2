defmodule PropertyTest do
  @moduledoc false

  use ExUnit.Case
  use ExUnitProperties

  alias BinaryTreeBag, as: Bag
  alias Monoid, as: M

  defp bags_equal?(bag1, bag2) do
    Bag.to_list(bag1) |> Enum.sort() == Bag.to_list(bag2) |> Enum.sort()
  end

  def bag_generator do
    gen all(elements <- list_of(integer())) do
      Enum.reduce(elements, Bag.new(), &Bag.add(&2, &1))
    end
  end

  def two_bags_generator do
    gen all(
          bag1 <- bag_generator(),
          bag2 <- bag_generator()
        ) do
      {bag1, bag2}
    end
  end

  def three_bags_generator do
    gen all(
          bag1 <- bag_generator(),
          bag2 <- bag_generator(),
          bag3 <- bag_generator()
        ) do
      {bag1, bag2, bag3}
    end
  end

  test "monoid: left identity" do
    check all(bag <- bag_generator()) do
      assert bags_equal?(M.concat(bag, M.empty()), bag)
    end
  end

  test "monoid: right identity" do
    check all(bag <- bag_generator()) do
      assert bags_equal?(M.concat(M.empty(), bag), bag)
    end
  end

  test "monoid: associativity" do
    check all({bag1, bag2, bag3} <- three_bags_generator()) do
      left_associative = M.concat(M.concat(bag1, bag2), bag3)
      right_associative = M.concat(bag1, M.concat(bag2, bag3))
      assert bags_equal?(left_associative, right_associative)
    end
  end

  test "size consistent with number of additions" do
    check all(elements <- list_of(integer())) do
      bag = Enum.reduce(elements, Bag.new(), &Bag.add(&2, &1))
      assert Bag.size(bag) == length(elements)
    end
  end

  test "add and remove single element" do
    check all(
            elements <- list_of(integer()),
            extra_element <- integer()
          ) do
      original_bag = Enum.reduce(elements, Bag.new(), &Bag.add(&2, &1))

      new_bag =
        original_bag
        |> Bag.add(extra_element)
        |> Bag.remove(extra_element)

      assert bags_equal?(original_bag, new_bag)
    end
  end

  test "convert to list and back preserves bag" do
    check all(bag <- bag_generator()) do
      converted_bag =
        bag
        |> Bag.to_list()
        |> Bag.from_list()

      assert bags_equal?(bag, converted_bag)
    end
  end
end
