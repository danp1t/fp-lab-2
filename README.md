# fp-lab-2
## Вариант bt-bag. Путинцев Данил

В рамках лабораторной работы вам предлагается реализовать одну из предложенных классических структур данных (список, дерево, бинарное дерево, hashmap, граф...).

Требования:

1. Функции:
    - добавление и удаление элементов;
    - фильтрация;
    - отображение (map);
    - свертки (левая и правая);
    - структура должна быть [моноидом](https://ru.m.wikipedia.org/wiki/Моноид).
2. Структуры данных должны быть неизменяемыми.
3. Библиотека должна быть протестирована в рамках unit testing.
4. Библиотека должна быть протестирована в рамках property-based тестирования (как минимум 3 свойства, включая свойства моноида).
5. Структура должна быть полиморфной.
6. Требуется использовать идиоматичный для технологии стиль программирования. Примечание: некоторые языки позволяют получить большую часть API через реализацию небольшого интерфейса. Так как лабораторная работа про ФП, а не про экосистему языка -- необходимо реализовать их вручную и по возможности -- обеспечить совместимость.
7. Обратите внимание:
    - API должно быть реализовано для заданного интерфейса и оно не должно "протекать". На уровне тестов -- в первую очередь нужно протестировать именно API (dict, set, bag).
    - Должна быть эффективная реализация функции сравнения (не наивное приведение к спискам, их сортировка с последующим сравнением), реализованная на уровне API, а не внутреннего представления.

## Операции наж Binary Tree Bag
### Добавление элементов
```elixir
def add(nil, value), do: {:node, value, 1, nil, nil}

# current - текущее значение элемента
# count - количество элементов
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
```

### Удаление элемента из дерева
```elixir
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

  # Объединение поддеревьев
defp merge_trees(nil, right), do: right
defp merge_trees(left, nil), do: left

defp merge_trees(left, right) do
    min_val = find_min(right)
    min_count = get_count(right, min_val)
    new_right = remove_min(right)
    {:node, min_val, min_count, left, new_right}
end
```
### Получение размера дерева
```elixir
def size(nil), do: 0

def size({:node, _, count, left, right}) do
    count + size(left) + size(right)
end
```

### Получение количества заданного элемента
```elixir
def count(nil, _), do: 0

def count({:node, value, count, left, right}, target) do
    cond do
      target < value ->
        count(left, target)

      target > value ->
        count(right, target)

      target == value ->
        count
    end
end
```

### Функция сравнения
```elixir
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
```
### Функция фильтрации
```elixir
def filter(bag, predicate) do
    bag
    |> to_list()
    |> Enum.filter(fn {value, _} -> predicate.(value) end)
    |> from_list()
end
```

### Функция отображения
```elixir
def map(bag, fun) do
    bag
    |> to_list()
    |> Enum.map(fn {value, count} -> {fun.(value), count} end)
    |> from_list()
end
```
### Свертка левая
```elixir
def foldl(bag, acc, fun) do
    do_foldl(bag, acc, fun)
  end

defp do_foldl(nil, acc, _fun), do: acc

defp do_foldl({:node, value, count, left, right}, acc, fun) do
    acc1 = do_foldl(left, acc, fun)
    acc2 = apply_multiple_times(value, count, acc1, fun)
    do_foldl(right, acc2, fun)
end
```

### Свертка правая
```elixir
def foldr(bag, acc, fun) do
    do_foldr(bag, acc, fun)
end

defp do_foldr(nil, acc, _fun), do: acc

defp do_foldr({:node, value, count, left, right}, acc, fun) do
    acc1 = do_foldr(right, acc, fun)
    acc2 = apply_multiple_times(value, count, acc1, fun)
    do_foldr(left, acc2, fun)
end
```

## Моноид
- Бинарная ассоциативная операция (concat)
- Нейтральный элемент (empty)

```elixir
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
```
