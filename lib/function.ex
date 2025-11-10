defmodule BagFunction do
  @moduledoc """
  Модуль для вспомогательных функций.
  """
  import BinaryTreeBag

  def filter(bag, predicate) do
    bag
    |> to_list()
    |> Enum.filter(fn {value, _} -> predicate.(value) end)
    |> from_list()
  end

  def map(bag, fun) do
    bag
    |> to_list()
    |> Enum.map(fn {value, count} -> {fun.(value), count} end)
    |> from_list()
  end

  def foldl(bag, acc, fun) do
    do_foldl(bag, acc, fun)
  end

  defp do_foldl(nil, acc, _fun), do: acc

  defp do_foldl({:node, value, count, left, right}, acc, fun) do
    acc1 = do_foldl(left, acc, fun)
    acc2 = apply_multiple_times(value, count, acc1, fun)
    do_foldl(right, acc2, fun)
  end

  def foldr(bag, acc, fun) do
    do_foldr(bag, acc, fun)
  end

  defp do_foldr(nil, acc, _fun), do: acc

  defp do_foldr({:node, value, count, left, right}, acc, fun) do
    acc1 = do_foldr(right, acc, fun)
    acc2 = apply_multiple_times(value, count, acc1, fun)
    do_foldr(left, acc2, fun)
  end

  defp apply_multiple_times(value, count, acc, fun) do
    Enum.reduce(1..count, acc, fn _, current_acc ->
      fun.(value, current_acc)
    end)
  end
end
