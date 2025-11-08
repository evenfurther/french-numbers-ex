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
      "moins " <> convert(-n, options)
    else
      convert(n, options)
    end
  end

  # Convert a non-negative integer to French
  defp convert(n, options) when n >= 0 do
    case get_literal(n, options) do
      nil -> convert_by_range(n, options)
      literal -> literal
    end
  end

  # Split conversion logic by number range
  defp convert_by_range(n, options) do
    cond do
      n < 60 -> smaller_than_60(n, options)
      n < 80 -> base_onto(60, n, options)
      n < 100 -> base_onto(80, n, options)
      n < 1000 -> smaller_than_1000(n, options)
      n < 2000 -> smaller_than_2000(n, options)
      n < 1_000_000 -> smaller_than_1000000(n, options)
      true -> over_1000000(n, options)
    end
  end

  # Get literal representation for specific values
  defp get_literal(1, %{feminine: true}), do: "une"
  defp get_literal(n, _options) when n <= 20, do: Enum.at(@smalls, n)
  defp get_literal(30, _options), do: "trente"
  defp get_literal(40, _options), do: "quarante"
  defp get_literal(50, _options), do: "cinquante"
  defp get_literal(60, _options), do: "soixante"
  defp get_literal(71, %{reformed: true}), do: "soixante-et-onze"
  defp get_literal(71, %{reformed: false}), do: "soixante et onze"
  defp get_literal(80, _options), do: "quatre-vingts"
  defp get_literal(81, %{feminine: true}), do: "quatre-vingt-une"
  defp get_literal(81, %{feminine: false}), do: "quatre-vingt-un"
  defp get_literal(100, _options), do: "cent"
  defp get_literal(1000, _options), do: "mille"
  defp get_literal(_value, _options), do: nil

  defp add_unit_for(str, prefix_count, log1000) do
    prefix_idx = div(log1000, 2)

    case Enum.fetch(@prefixes, prefix_idx) do
      {:ok, prefix} ->
        suffix = if rem(log1000, 2) == 0, do: "illion", else: "illiard"
        plural = if prefix_count > 1, do: "s", else: ""
        str <> prefix <> suffix <> plural

      :error ->
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

  defp complete(str, 0, _prefix_under_100, _options), do: str

  defp complete(str, 1, prefix_under_100, options) do
    str = unpluralize(str)
    connector = get_connector(prefix_under_100, options.reformed)
    suffix = if options.feminine, do: "e", else: ""
    str <> connector <> suffix
  end

  defp complete(str, n, prefix_under_100, options) do
    str = unpluralize(str)
    separator = get_separator(prefix_under_100, n, options.reformed)
    str <> separator <> convert(n, options)
  end

  defp get_connector(true, true), do: "-et-un"
  defp get_connector(true, false), do: " et un"
  defp get_connector(false, true), do: "-un"
  defp get_connector(false, false), do: " un"

  defp get_separator(true, n, _reformed) when n < 100, do: "-"
  defp get_separator(_prefix_under_100, _n, true), do: "-"
  defp get_separator(_prefix_under_100, _n, false), do: " "

  defp smaller_than_60(n, options) do
    unit = rem(n, 10)
    complete(convert(n - unit, %{options | feminine: false}), unit, true, options)
  end

  defp base_onto(b, n, options) do
    complete(get_literal(b, options), n - b, true, options)
  end

  defp smaller_than_1000(n, options) do
    hundredths = div(n, 100)
    rest = rem(n, 100)

    result =
      if hundredths > 1 do
        prefix = get_literal(hundredths, options)
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

    prefix = build_thousands_prefix(thousands, options)
    complete(prefix, rest, false, options)
  end

  defp build_thousands_prefix(1, _options), do: "mille"

  defp build_thousands_prefix(thousands, options) do
    thousands_str = convert(thousands, %{options | feminine: false})
    thousands_str = unpluralize(thousands_str)
    separator = if options.reformed, do: "-", else: " "
    thousands_str <> separator <> "mille"
  end

  defp over_1000000(n, options) do
    small = rem(n, 1_000_000)
    num = div(n, 1_000_000)

    base = if small == 0, do: nil, else: convert(small, options)
    result = build_large_number(num, base, options, 0)

    result || Integer.to_string(n)
  end

  defp build_large_number(0, base, _options, _log1000), do: base

  defp build_large_number(num, base, options, log1000) do
    prefix = rem(num, 1000)
    rest = div(num, 1000)

    new_base = build_next_base(prefix, base, options, log1000)

    if new_base do
      build_large_number(rest, new_base, options, log1000 + 1)
    end
  end

  defp build_next_base(0, base, _options, _log1000), do: base

  defp build_next_base(prefix, base, options, log1000) do
    str = convert(prefix, %{options | feminine: false})
    separator = if options.reformed, do: "-", else: " "

    case add_unit_for(str <> separator, prefix, log1000) do
      nil -> nil
      unit_str -> append_base(unit_str, base, options)
    end
  end

  defp append_base(unit_str, nil, _options), do: unit_str

  defp append_base(unit_str, base, options) do
    separator = if options.reformed, do: "-", else: " "
    unit_str <> separator <> base
  end
end
