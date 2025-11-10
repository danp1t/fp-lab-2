defmodule PropertyTest do
  @moduledoc false

  use ExUnit.Case
  use ExUnitProperties

  alias BinaryTreeBag, as: Bag
  alias BagFunction, as: BF
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
      left_identity = M.concat(bag, M.empty())
      assert bags_equal?(left_identity, bag)
    end
  end

  test "monoid: right identity" do
    check all(bag <- bag_generator()) do
      right_identity = M.concat(M.empty(), bag)
      assert bags_equal?(right_identity, bag)
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

      original_count = Bag.count(original_bag, extra_element)

      if original_count == 0 do
        assert bags_equal?(original_bag, new_bag)
      else
        assert Bag.count(new_bag, extra_element) == original_count
      end
    end
  end

  test "filter preserves elements satisfying condition" do
    check all(bag <- bag_generator()) do
      filtered = BF.filter(bag, fn x -> rem(x, 2) == 0 end)

      all_elements_even =
        BF.foldl(filtered, true, fn
          x, acc -> acc and rem(x, 2) == 0
        end)

      assert all_elements_even == true
    end
  end

  test "map applies function to all elements" do
    check all(bag <- bag_generator()) do
      mapped = BF.map(bag, fn x -> x * 2 end)

      original_list = Bag.to_list(bag)
      mapped_list = Bag.to_list(mapped)

      expected_mapped = Enum.map(original_list, fn {value, count} -> {value * 2, count} end)

      assert Enum.sort(mapped_list) == Enum.sort(expected_mapped)
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

  test "concatenating identical bags doubles element counts" do
    check all(bag <- bag_generator()) do
      doubled_bag = M.concat(bag, bag)

      all_doubled =
        BF.foldl(bag, true, fn value, acc ->
          original_count = Bag.count(bag, value)
          doubled_count = Bag.count(doubled_bag, value)
          acc and doubled_count == original_count * 2
        end)

      assert all_doubled == true
    end
  end

  test "size of combined bags" do
    check all({bag1, bag2} <- two_bags_generator()) do
      combined = M.concat(bag1, bag2)
      expected_size = Bag.size(bag1) + Bag.size(bag2)
      assert Bag.size(combined) == expected_size
    end
  end
end
