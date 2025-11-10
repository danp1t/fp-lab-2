defmodule Monoid do
  @moduledoc """
  Модуль для проверки на моноид.
  """
  import BinaryTreeBag

  def empty(), do: nil

  def concat(bag1, bag2) do
    list1 = to_list(bag1)
    list2 = to_list(bag2)
    combined = combine_lists(list1, list2)
    from_list(combined)
  end

  defp combine_lists([], list2), do: list2
  defp combine_lists(list1, []), do: list1

  defp combine_lists([{val1, count1} | rest1], [{val2, count2} | rest2]) do
    if val1 < val2 do
      [{val1, count1} | combine_lists(rest1, [{val2, count2} | rest2])]
    else
      if val1 > val2 do
        [{val2, count2} | combine_lists([{val1, count1} | rest1], rest2)]
      else
        [{val1, count1 + count2} | combine_lists(rest1, rest2)]
      end
    end
  end
end
