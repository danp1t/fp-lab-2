defmodule BinaryTreeBag do
  @moduledoc """
  Реализация bt-bag
  """
  def new(), do: nil

  def empty?(nil), do: true
  def empty?(_), do: false

  def add(nil, value), do: {:node, value, 1, nil, nil}

  def add({:node, current, count, left, right}, value) do
    if value < current do
      {:node, current, count, add(left, value), right}
    else
      if value > current do
        {:node, current, count, left, add(right, value)}
      else
        {:node, current, count + 1, left, right}
      end
    end
  end

  def remove(nil, _), do: nil

  def remove({:node, current, count, left, right}, value) do
    cond do
      value < current ->
        {:node, current, count, remove(left, value), right}

      value > current ->
        {:node, current, count, left, remove(right, value)}

      count > 1 ->
        {:node, current, count - 1, left, right}

      true ->
        merge_trees(left, right)
    end
  end

  defp merge_trees(nil, right), do: right
  defp merge_trees(left, nil), do: left

  defp merge_trees(left, right) do
    min_val = find_min(right)
    min_count = get_count(right, min_val)
    new_right = remove_min(right)
    {:node, min_val, min_count, left, new_right}
  end

  defp find_min({:node, value, _, nil, _}), do: value
  defp find_min({:node, _, _, left, _}), do: find_min(left)

  defp get_count({:node, value, count, _, _}, target) when value == target, do: count

  defp get_count({:node, value, _, left, _}, target) when target < value,
    do: get_count(left, target)

  defp get_count({:node, _, _, _, right}, target), do: get_count(right, target)

  defp remove_min({:node, _, _, nil, right}), do: right

  defp remove_min({:node, value, count, left, right}) do
    {:node, value, count, remove_min(left), right}
  end

  def size(nil), do: 0

  def size({:node, _, count, left, right}) do
    count + size(left) + size(right)
  end

  def member?(nil, _), do: false

  def member?({:node, value, _, left, right}, target) do
    if target < value do
      member?(left, target)
    else
      if target > value do
        member?(right, target)
      else
        true
      end
    end
  end

  def count(nil, _), do: 0

  def count({:node, value, count, left, right}, target) do
    if target < value do
      count(left, target)
    else
      if target > value do
        count(right, target)
      else
        count
      end
    end
  end

  def to_list(bag) do
    do_to_list(bag, [])
  end

  defp do_to_list(nil, acc), do: acc

  defp do_to_list({:node, value, count, left, right}, acc) do
    acc1 = do_to_list(left, acc)
    acc2 = [{value, count} | acc1]
    do_to_list(right, acc2)
  end

  def from_list(list) do
    Enum.reduce(list, new(), fn {value, count}, bag ->
      add_multiple(bag, value, count)
    end)
  end

  defp add_multiple(bag, _value, 0), do: bag

  defp add_multiple(bag, value, count) do
    add_multiple(add(bag, value), value, count - 1)
  end

  def equal?(nil, nil), do: true
  def equal?(nil, _), do: false
  def equal?(_, nil), do: false

  def equal?(bag1, bag2) do
    compare_trees(bag1, bag2)
  end

  defp compare_trees(nil, nil), do: true
  defp compare_trees(nil, _), do: false
  defp compare_trees(_, nil), do: false

  defp compare_trees({:node, v1, c1, l1, r1}, {:node, v2, c2, l2, r2}) do
    v1 == v2 and c1 == c2 and compare_trees(l1, l2) and compare_trees(r1, r2)
  end
end
