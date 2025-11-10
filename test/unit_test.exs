defmodule UnitTest do
  use ExUnit.Case

  alias BinaryTreeBag, as: Bag
  alias BagFunction, as: BF
  alias Monoid, as: M

  defp bags_equal?(bag1, bag2) do
    Bag.to_list(bag1) |> Enum.sort() == Bag.to_list(bag2) |> Enum.sort()
  end

  describe "basic operations" do
    test "create empty bag" do
      bag = Bag.new()
      assert Bag.empty?(bag) == true
      assert Bag.size(bag) == 0
    end

    test "add elements" do
      bag =
        Bag.new()
        |> Bag.add(5)
        |> Bag.add(3)
        |> Bag.add(5)

      assert Bag.empty?(bag) == false
      assert Bag.size(bag) == 3
      assert Bag.count(bag, 5) == 2
      assert Bag.count(bag, 3) == 1
    end

    test "remove elements" do
      bag =
        Bag.new()
        |> Bag.add(5)
        |> Bag.add(3)
        |> Bag.add(5)
        |> Bag.remove(5)

      assert Bag.count(bag, 5) == 1
      assert Bag.count(bag, 3) == 1
      assert Bag.size(bag) == 2
    end

    test "remove non-existent element" do
      bag =
        Bag.new()
        |> Bag.add(1)
        |> Bag.remove(999)

      assert Bag.size(bag) == 1
      assert Bag.count(bag, 1) == 1
    end

    test "check element membership" do
      bag =
        Bag.new()
        |> Bag.add(1)
        |> Bag.add(2)

      assert Bag.member?(bag, 1) == true
      assert Bag.member?(bag, 2) == true
      assert Bag.member?(bag, 999) == false
    end
  end

  describe "higher-order functions" do
    test "filter" do
      bag =
        Bag.new()
        |> Bag.add(1)
        |> Bag.add(2)
        |> Bag.add(3)
        |> Bag.add(1)

      filtered = BF.filter(bag, fn x -> rem(x, 2) == 0 end)

      assert Bag.count(filtered, 1) == 0
      assert Bag.count(filtered, 2) == 1
      assert Bag.count(filtered, 3) == 0
    end

    test "map" do
      bag =
        Bag.new()
        |> Bag.add(1)
        |> Bag.add(2)
        |> Bag.add(1)

      mapped = BF.map(bag, fn x -> x * 2 end)

      assert Bag.count(mapped, 2) == 2
      assert Bag.count(mapped, 4) == 1
    end

    test "left fold (foldl)" do
      bag =
        Bag.new()
        |> Bag.add(1)
        |> Bag.add(2)
        |> Bag.add(3)

      sum = BF.foldl(bag, 0, fn x, acc -> x + acc end)
      assert sum == 6

      list = BF.foldl(bag, [], fn x, acc -> [x | acc] end)
      assert Enum.sum(list) == 6
    end

    test "right fold (foldr)" do
      bag =
        Bag.new()
        |> Bag.add(1)
        |> Bag.add(2)
        |> Bag.add(3)

      list = BF.foldr(bag, [], fn x, acc -> [x | acc] end)
      assert Enum.sum(list) == 6
    end
  end

  describe "monoid operations" do
    test "empty element" do
      empty_bag = M.empty()
      assert Bag.empty?(empty_bag) == true
      assert Bag.size(empty_bag) == 0
    end

    test "combine two bags" do
      bag1 = Bag.new() |> Bag.add(1) |> Bag.add(2)
      bag2 = Bag.new() |> Bag.add(2) |> Bag.add(3)

      combined = M.concat(bag1, bag2)

      assert Bag.count(combined, 1) == 1
      assert Bag.count(combined, 2) == 2
      assert Bag.count(combined, 3) == 1
    end

    test "combine with empty bag" do
      bag = Bag.new() |> Bag.add(1) |> Bag.add(2)
      empty_bag = M.empty()

      assert bags_equal?(M.concat(bag, empty_bag), bag)
      assert bags_equal?(M.concat(empty_bag, bag), bag)
    end
  end

  describe "transformations" do
    test "convert to list and back" do
      original_bag =
        Bag.new()
        |> Bag.add(3)
        |> Bag.add(1)
        |> Bag.add(2)
        |> Bag.add(1)

      list = Bag.to_list(original_bag)
      new_bag = Bag.from_list(list)

      assert bags_equal?(original_bag, new_bag)
    end

    test "bag comparison" do
      bag1 = Bag.new() |> Bag.add(1) |> Bag.add(2) |> Bag.add(1)
      bag2 = Bag.new() |> Bag.add(1) |> Bag.add(1) |> Bag.add(2)
      bag3 = Bag.new() |> Bag.add(1) |> Bag.add(3)

      assert bags_equal?(bag1, bag2) == true
      assert bags_equal?(bag1, bag3) == false
      assert bags_equal?(bag2, bag3) == false
    end
  end

  describe "edge cases" do
    test "remove from empty bag" do
      empty_bag = Bag.new()
      result = Bag.remove(empty_bag, 1)
      assert Bag.empty?(result) == true
    end

    test "add and remove single element" do
      bag = Bag.new() |> Bag.add(5) |> Bag.remove(5)
      assert Bag.empty?(bag) == true
    end

    test "multiple additions and removals" do
      bag = Bag.new() |> Bag.add(1) |> Bag.add(1) |> Bag.add(1) |> Bag.remove(1) |> Bag.remove(1)

      assert Bag.count(bag, 1) == 1
      assert Bag.size(bag) == 1
    end
  end
end
