# FrenchNumbers

FrenchNumbers is an Elixir library that transforms numbers into their French representation.

This library replicates the functionality of the Rust [`french-numbers`](https://github.com/evenfurther/french-numbers) crate.

## Installation

Add `french_numbers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:french_numbers, "~> 0.1.0"}
  ]
end
```

## Usage

Use the `FrenchNumbers.to_french/2` function to convert any integer to its French representation:

```elixir
iex> FrenchNumbers.to_french(71)
"soixante-et-onze"

iex> FrenchNumbers.to_french(1001)
"mille-un"

iex> FrenchNumbers.to_french(-200001)
"moins deux-cent-mille-un"

iex> FrenchNumbers.to_french(-200000001)
"moins deux-cents-millions-un"

iex> FrenchNumbers.to_french(-204000001)
"moins deux-cent-quatre-millions-un"
```

## Options

You can customize the output using keyword options:

### Feminine Form

Use the `:feminine` option (default: `false`) to get the feminine declination. This only affects numbers ending in 1:

```elixir
iex> FrenchNumbers.to_french(37251061, feminine: false)
"trente-sept-millions-deux-cent-cinquante-et-un-mille-soixante-et-un"

iex> FrenchNumbers.to_french(37251061, feminine: true)
"trente-sept-millions-deux-cent-cinquante-et-un-mille-soixante-et-une"
```

### Orthographic Reform

Use the `:reformed` option (default: `true`) to control the hyphenation style:

- `true` (default): Post-1990 reform - all words are separated by hyphens
- `false`: Pre-1990 - only numbers smaller than 100 are separated by hyphens, others by spaces

```elixir
iex> FrenchNumbers.to_french(37251061, reformed: true)
"trente-sept-millions-deux-cent-cinquante-et-un-mille-soixante-et-un"

iex> FrenchNumbers.to_french(37251061, reformed: false)
"trente-sept millions deux cent cinquante et un mille soixante et un"
```

You can combine both options:

```elixir
iex> FrenchNumbers.to_french(37251061, feminine: true, reformed: false)
"trente-sept millions deux cent cinquante et un mille soixante et une"
```

## Testing

The library includes comprehensive tests ported from the Rust crate, including:

- 10,000 test cases for reformed format
- 10,000 test cases for pre-reform format
- Tests from various French language resources

Run tests with:

```bash
mix test
```

## License

This project follows the same license as the original Rust crate.
