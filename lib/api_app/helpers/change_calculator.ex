defmodule ApiApp.Helpers.ChangeCalculator do
  @coin_values [100, 50, 20, 10, 5]

  def calculate_change(amount) when is_integer(amount) and amount >= 0 do
    calculate_change(amount, @coin_values, [])
  end

  defp calculate_change(0, _, result), do: Enum.reverse(result)

  defp calculate_change(_amount, [], _), do: :error  # Not enough coins to make change

  defp calculate_change(amount, [coin | rest], result) do
    if amount >= coin do
      num_coins = div(amount, coin)
      new_amount = rem(amount, coin)
      new_result = Enum.concat(result, List.duplicate(coin, num_coins))
      calculate_change(new_amount, rest, new_result)
    else
      calculate_change(amount, rest, result)
    end
  end
end
