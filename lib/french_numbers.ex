defmodule FrenchNumbers do
  @moduledoc """
  This module transforms a number into its French representation.

  ## Examples

      iex> FrenchNumbers.to_french(71)
      "soixante-et-onze"
      
      iex> FrenchNumbers.to_french(1001)
      "mille-un"
      
      iex> FrenchNumbers.to_french(-200001)
      "moins deux-cent-mille-un"
      
      iex> FrenchNumbers.to_french(37251061, feminine: true)
      "trente-sept-millions-deux-cent-cinquante-et-un-mille-soixante-et-une"
      
      iex> FrenchNumbers.to_french(37251061, reformed: false)
      "trente-sept millions deux cent cinquante et un mille soixante et un"
  """

  @smalls [
    "zéro",
    "un",
    "deux",
    "trois",
    "quatre",
    "cinq",
    "six",
    "sept",
    "huit",
    "neuf",
    "dix",
    "onze",
    "douze",
    "treize",
    "quatorze",
    "quinze",
    "seize",
    "dix-sept",
    "dix-huit",
    "dix-neuf",
    "vingt"
  ]

  @prefixes [
    "m",
    "b",
    "tr",
    "quadr",
    "quint",
    "sext",
    "sept",
    "oct",
    "non",
    "déc",
    "unodéc",
    "duodéc",
    "trédéc",
    "quattuordéc",
    "quindéc",
    "sexdéc"
  ]

  @doc """
  Convert a number to its French textual representation.

  ## Options

    * `:feminine` - Use the feminine declination (default: `false`). This only affects numbers ending in 1.
    * `:reformed` - Use the post-1990 orthographic reform with hyphens everywhere (default: `true`).
                    Set to `false` for pre-1990 format with spaces between words greater than 100.

  ## Examples

      iex> FrenchNumbers.to_french(17)
      "dix-sept"
      
      iex> FrenchNumbers.to_french(1, feminine: true)
      "une"
      
      iex> FrenchNumbers.to_french(21, reformed: false)
      "vingt et un"
  """
  def to_french(n, opts \\ []) when is_integer(n) do
    options = %{
      feminine: Keyword.get(opts, :feminine, false),
      reformed: Keyword.get(opts, :reformed, true)
    }

    if n < 0 do
      "moins " <> basic(-n, options, false)
    else
      basic(n, options, false)
    end
  end

  defp literal_for(value, options) do
    cond do
      value == 1 and options.feminine -> "une"
      value <= 20 -> Enum.at(@smalls, value)
      value == 30 -> "trente"
      value == 40 -> "quarante"
      value == 50 -> "cinquante"
      value == 60 -> "soixante"
      value == 71 -> if options.reformed, do: "soixante-et-onze", else: "soixante et onze"
      value == 80 -> "quatre-vingts"
      value == 81 -> if options.feminine, do: "quatre-vingt-une", else: "quatre-vingt-un"
      value == 100 -> "cent"
      value == 1000 -> "mille"
      true -> nil
    end
  end

  defp add_unit_for(str, prefix_count, log1000) do
    prefix_idx = div(log1000, 2)

    if prefix_idx < length(@prefixes) do
      prefix = Enum.at(@prefixes, prefix_idx)
      suffix = if rem(log1000, 2) == 0, do: "illion", else: "illiard"
      plural = if prefix_count > 1, do: "s", else: ""
      str <> prefix <> suffix <> plural
    else
      nil
    end
  end

  defp unpluralize(str) do
    if String.ends_with?(str, "ts") do
      String.slice(str, 0..-2//1)
    else
      str
    end
  end

  defp complete(str, n, prefix_under_100, options) do
    if n > 0 do
      str = unpluralize(str)

      str =
        if n == 1 do
          connector =
            cond do
              prefix_under_100 and options.reformed -> "-et-un"
              prefix_under_100 -> " et un"
              options.reformed -> "-un"
              true -> " un"
            end

          str <> connector <> if(options.feminine, do: "e", else: "")
        else
          separator =
            if options.reformed or (prefix_under_100 and n < 100) do
              "-"
            else
              " "
            end

          str <> separator <> basic(n, options, false)
        end

      str
    else
      str
    end
  end

  defp basic(n, options, _negative) when n >= 0 do
    case literal_for(n, options) do
      nil ->
        cond do
          n < 60 -> smaller_than_60(n, options)
          n < 80 -> base_onto(60, n, options)
          n < 100 -> base_onto(80, n, options)
          n < 1000 -> smaller_than_1000(n, options)
          n < 2000 -> smaller_than_2000(n, options)
          n < 1_000_000 -> smaller_than_1000000(n, options)
          true -> over_1000000(n, options)
        end

      literal ->
        literal
    end
  end

  defp smaller_than_60(n, options) do
    unit = rem(n, 10)
    complete(basic(n - unit, %{options | feminine: false}, false), unit, true, options)
  end

  defp base_onto(b, n, options) do
    complete(literal_for(b, options), n - b, true, options)
  end

  defp smaller_than_1000(n, options) do
    hundredths = div(n, 100)
    rest = rem(n, 100)

    result =
      if hundredths > 1 do
        prefix = literal_for(hundredths, options)
        separator = if options.reformed, do: "-", else: " "
        prefix <> separator <> "cents"
      else
        "cent"
      end

    complete(result, rest, false, options)
  end

  defp smaller_than_2000(n, options) do
    complete("mille", n - 1000, false, options)
  end

  defp smaller_than_1000000(n, options) do
    thousands = div(n, 1000)
    rest = rem(n, 1000)

    prefix =
      if thousands > 1 do
        thousands_str = basic(thousands, %{options | feminine: false}, false)
        thousands_str = unpluralize(thousands_str)
        separator = if options.reformed, do: "-", else: " "
        thousands_str <> separator <> "mille"
      else
        "mille"
      end

    complete(prefix, rest, false, options)
  end

  defp over_1000000(n, options) do
    small = rem(n, 1_000_000)
    num = div(n, 1_000_000)

    base =
      if small == 0 do
        nil
      else
        basic(small, options, false)
      end

    {result, _log1000} = build_large_number(num, base, options, 0)

    case result do
      nil -> Integer.to_string(n)
      str -> str
    end
  end

  defp build_large_number(0, base, _options, log1000), do: {base, log1000}

  defp build_large_number(num, base, options, log1000) do
    prefix = rem(num, 1000)
    rest = div(num, 1000)

    base =
      if prefix > 0 do
        str = basic(prefix, %{options | feminine: false}, false)
        separator = if options.reformed, do: "-", else: " "

        case add_unit_for(str <> separator, prefix, log1000) do
          nil ->
            nil

          unit_str ->
            if base do
              separator = if options.reformed, do: "-", else: " "
              unit_str <> separator <> base
            else
              unit_str
            end
        end
      else
        base
      end

    if base == nil do
      {nil, log1000}
    else
      build_large_number(rest, base, options, log1000 + 1)
    end
  end
end
