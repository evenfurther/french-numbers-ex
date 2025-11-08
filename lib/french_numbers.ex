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

  @small_numbers [
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

  @large_scale_prefixes [
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
      n < 60 -> convert_compound_under_60(n, options)
      n < 80 -> convert_with_base(60, n, options)
      n < 100 -> convert_with_base(80, n, options)
      n < 1000 -> convert_hundreds(n, options)
      n < 2000 -> convert_one_thousand_and_remainder(n, options)
      n < 1_000_000 -> convert_thousands(n, options)
      true -> convert_millions_and_above(n, options)
    end
  end

  # Get literal representation for specific values
  defp get_literal(1, %{feminine: true}), do: "une"
  defp get_literal(n, _options) when n <= 20, do: Enum.at(@small_numbers, n)
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

  # Build large scale unit names (million, milliard, billion, etc.)
  defp build_large_scale_unit(str, count, scale_level) do
    prefix_idx = div(scale_level, 2)

    case Enum.fetch(@large_scale_prefixes, prefix_idx) do
      {:ok, prefix} ->
        suffix = if rem(scale_level, 2) == 0, do: "illion", else: "illiard"
        plural = if count > 1, do: "s", else: ""
        str <> prefix <> suffix <> plural

      :error ->
        nil
    end
  end

  # Remove plural marker from words ending in "ts"
  defp remove_plural_s(str) do
    if String.ends_with?(str, "ts") do
      String.slice(str, 0..-2//1)
    else
      str
    end
  end

  # Append remainder to base number string
  defp append_remainder(base_str, 0, _has_base_under_100, _options), do: base_str

  defp append_remainder(base_str, 1, has_base_under_100, options) do
    base_str = remove_plural_s(base_str)
    one_suffix = get_unit_one_suffix(has_base_under_100, options.reformed)
    feminine_suffix = if options.feminine, do: "e", else: ""
    base_str <> one_suffix <> feminine_suffix
  end

  defp append_remainder(base_str, remainder, has_base_under_100, options) do
    base_str = remove_plural_s(base_str)
    separator = get_separator(has_base_under_100, remainder, options.reformed)
    base_str <> separator <> convert(remainder, options)
  end

  # Get the suffix to append for unit "one" (un/une)
  defp get_unit_one_suffix(true, true), do: "-et-un"
  defp get_unit_one_suffix(true, false), do: " et un"
  defp get_unit_one_suffix(false, true), do: "-un"
  defp get_unit_one_suffix(false, false), do: " un"

  # Get separator between number parts
  defp get_separator(true, remainder, _reformed) when remainder < 100, do: "-"
  defp get_separator(_has_base_under_100, _remainder, true), do: "-"
  defp get_separator(_has_base_under_100, _remainder, false), do: " "

  # Convert compound numbers under 60 (e.g., 21-59)
  defp convert_compound_under_60(n, options) do
    units = rem(n, 10)
    tens_part = convert(n - units, %{options | feminine: false})
    append_remainder(tens_part, units, true, options)
  end

  # Convert numbers using a base (e.g., 60 + 15 = soixante-quinze)
  defp convert_with_base(base, n, options) do
    base_str = get_literal(base, options)
    remainder = n - base
    append_remainder(base_str, remainder, true, options)
  end

  # Convert hundreds (100-999)
  defp convert_hundreds(n, options) do
    hundreds = div(n, 100)
    remainder = rem(n, 100)

    base_str =
      if hundreds > 1 do
        hundreds_word = get_literal(hundreds, options)
        separator = if options.reformed, do: "-", else: " "
        hundreds_word <> separator <> "cents"
      else
        "cent"
      end

    append_remainder(base_str, remainder, false, options)
  end

  # Convert 1000-1999 (special case: "mille" instead of "un-mille")
  defp convert_one_thousand_and_remainder(n, options) do
    remainder = n - 1000
    append_remainder("mille", remainder, false, options)
  end

  # Convert thousands (1000-999999)
  defp convert_thousands(n, options) do
    thousands = div(n, 1000)
    remainder = rem(n, 1000)

    base_str = build_thousands_part(thousands, options)
    append_remainder(base_str, remainder, false, options)
  end

  defp build_thousands_part(1, _options), do: "mille"

  defp build_thousands_part(thousands, options) do
    thousands_str = convert(thousands, %{options | feminine: false})
    thousands_str = remove_plural_s(thousands_str)
    separator = if options.reformed, do: "-", else: " "
    thousands_str <> separator <> "mille"
  end

  # Convert millions and larger numbers
  defp convert_millions_and_above(n, options) do
    remainder_under_million = rem(n, 1_000_000)
    millions_part = div(n, 1_000_000)

    base_str =
      if remainder_under_million == 0,
        do: nil,
        else: convert(remainder_under_million, options)

    result = build_large_number_recursively(millions_part, base_str, options, 0)

    result || Integer.to_string(n)
  end

  defp build_large_number_recursively(0, accumulated, _options, _scale_level),
    do: accumulated

  defp build_large_number_recursively(remaining, accumulated, options, scale_level) do
    current_triplet = rem(remaining, 1000)
    next_remaining = div(remaining, 1000)

    new_accumulated = append_large_scale_part(current_triplet, accumulated, options, scale_level)

    if new_accumulated do
      build_large_number_recursively(next_remaining, new_accumulated, options, scale_level + 1)
    end
  end

  defp append_large_scale_part(0, accumulated, _options, _scale_level), do: accumulated

  defp append_large_scale_part(triplet_value, accumulated, options, scale_level) do
    triplet_str = convert(triplet_value, %{options | feminine: false})
    separator = if options.reformed, do: "-", else: " "

    case build_large_scale_unit(triplet_str <> separator, triplet_value, scale_level) do
      nil -> nil
      unit_with_scale -> join_with_smaller_part(unit_with_scale, accumulated, options)
    end
  end

  defp join_with_smaller_part(larger_part, nil, _options), do: larger_part

  defp join_with_smaller_part(larger_part, smaller_part, options) do
    separator = if options.reformed, do: "-", else: " "
    larger_part <> separator <> smaller_part
  end
end
