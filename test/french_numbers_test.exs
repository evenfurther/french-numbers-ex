defmodule FrenchNumbersTest do
  use ExUnit.Case
  doctest FrenchNumbers

  test "basic french numbers" do
    assert FrenchNumbers.to_french(-17_000) == "moins dix-sept-mille"
    assert FrenchNumbers.to_french(-17_000_000) == "moins dix-sept-millions"
    assert FrenchNumbers.to_french(900) == "neuf-cents"
    assert FrenchNumbers.to_french(901) == "neuf-cent-un"
    assert FrenchNumbers.to_french(17_000_000) == "dix-sept-millions"

    assert FrenchNumbers.to_french(220_130_202) ==
             "deux-cent-vingt-millions-cent-trente-mille-deux-cent-deux"

    assert FrenchNumbers.to_french(1_220_080_380_200) ==
             "un-billion-deux-cent-vingt-milliards-quatre-vingts-millions-trois-cent-quatre-vingt-mille-deux-cents"
  end

  test "feminine forms" do
    assert FrenchNumbers.to_french(1, feminine: true) == "une"
    assert FrenchNumbers.to_french(21, feminine: true) == "vingt-et-une"
    assert FrenchNumbers.to_french(71, feminine: true) == "soixante-et-onze"
    assert FrenchNumbers.to_french(81, feminine: true) == "quatre-vingt-une"
    assert FrenchNumbers.to_french(21_001, feminine: true) == "vingt-et-un-mille-une"

    assert FrenchNumbers.to_french(1_021_001, feminine: true) ==
             "un-million-vingt-et-un-mille-une"

    assert FrenchNumbers.to_french(101_021_001, feminine: true) ==
             "cent-un-millions-vingt-et-un-mille-une"
  end

  test "unreformed (pre-1990) format" do
    assert FrenchNumbers.to_french(1, reformed: false) == "un"
    assert FrenchNumbers.to_french(21, reformed: false) == "vingt et un"
    assert FrenchNumbers.to_french(71, reformed: false) == "soixante et onze"
    assert FrenchNumbers.to_french(21_001, reformed: false) == "vingt et un mille un"

    assert FrenchNumbers.to_french(1_021_001, reformed: false) ==
             "un million vingt et un mille un"

    assert FrenchNumbers.to_french(1_027_001, reformed: false) ==
             "un million vingt-sept mille un"

    assert FrenchNumbers.to_french(101_021_037, reformed: false) ==
             "cent un millions vingt et un mille trente-sept"
  end

  test "podcastfrancaisfacile examples" do
    # From http://www.podcastfrancaisfacile.com/
    assert FrenchNumbers.to_french(3641, reformed: false) ==
             "trois mille six cent quarante et un"

    assert FrenchNumbers.to_french(2984, reformed: false) ==
             "deux mille neuf cent quatre-vingt-quatre"

    assert FrenchNumbers.to_french(7129, reformed: false) == "sept mille cent vingt-neuf"

    assert FrenchNumbers.to_french(1891, reformed: false) ==
             "mille huit cent quatre-vingt-onze"

    assert FrenchNumbers.to_french(2820, reformed: false) == "deux mille huit cent vingt"

    assert FrenchNumbers.to_french(1734, reformed: false) ==
             "mille sept cent trente-quatre"

    assert FrenchNumbers.to_french(1986, reformed: false) ==
             "mille neuf cent quatre-vingt-six"

    assert FrenchNumbers.to_french(6012, reformed: false) == "six mille douze"
    assert FrenchNumbers.to_french(1930, reformed: false) == "mille neuf cent trente"
    assert FrenchNumbers.to_french(9021, reformed: false) == "neuf mille vingt et un"

    assert FrenchNumbers.to_french(5555, reformed: false) ==
             "cinq mille cinq cent cinquante-cinq"

    assert FrenchNumbers.to_french(8080, reformed: false) == "huit mille quatre-vingts"

    assert FrenchNumbers.to_french(6728, reformed: false) ==
             "six mille sept cent vingt-huit"

    assert FrenchNumbers.to_french(2773, reformed: false) ==
             "deux mille sept cent soixante-treize"

    assert FrenchNumbers.to_french(1839, reformed: false) ==
             "mille huit cent trente-neuf"

    assert FrenchNumbers.to_french(5391, reformed: false) ==
             "cinq mille trois cent quatre-vingt-onze"

    assert FrenchNumbers.to_french(3100, reformed: false) == "trois mille cent"

    assert FrenchNumbers.to_french(1193, reformed: false) ==
             "mille cent quatre-vingt-treize"

    assert FrenchNumbers.to_french(4722, reformed: false) ==
             "quatre mille sept cent vingt-deux"

    assert FrenchNumbers.to_french(6382, reformed: false) ==
             "six mille trois cent quatre-vingt-deux"
  end

  test "educastream examples" do
    # From http://www.educastream.com/ecrire-grands-nombres-cm2
    assert FrenchNumbers.to_french(1_236_458, reformed: false) ==
             "un million deux cent trente-six mille quatre cent cinquante-huit"

    assert FrenchNumbers.to_french(74_521_890, reformed: false) ==
             "soixante-quatorze millions cinq cent vingt et un mille huit cent quatre-vingt-dix"

    assert FrenchNumbers.to_french(2_530_647_918, reformed: false) ==
             "deux milliards cinq cent trente millions six cent quarante-sept mille neuf cent dix-huit"

    assert FrenchNumbers.to_french(1_234_569, reformed: false) ==
             "un million deux cent trente-quatre mille cinq cent soixante-neuf"

    assert FrenchNumbers.to_french(20_263_400, reformed: false) ==
             "vingt millions deux cent soixante-trois mille quatre cents"
  end

  test "termiumplus examples" do
    # From https://www.btb.termiumplus.gc.ca/
    assert FrenchNumbers.to_french(1283, reformed: false) ==
             "mille deux cent quatre-vingt-trois"

    assert FrenchNumbers.to_french(10_300_000_000, reformed: false) ==
             "dix milliards trois cents millions"

    assert FrenchNumbers.to_french(10_350_000_000, reformed: false) ==
             "dix milliards trois cent cinquante millions"

    assert FrenchNumbers.to_french(1283) == "mille-deux-cent-quatre-vingt-trois"

    assert FrenchNumbers.to_french(10_300_000_000) ==
             "dix-milliards-trois-cents-millions"

    assert FrenchNumbers.to_french(10_350_000_000) ==
             "dix-milliards-trois-cent-cinquante-millions"
  end

  defp check_reference(file, opts) do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.each(fn line ->
      line = String.trim(line)

      unless line == "" do
        [num_str, expected] = String.split(line, " ", parts: 2)
        n = String.to_integer(num_str)
        assert FrenchNumbers.to_french(n, opts) == expected
      end
    end)
  end

  test "reference file - post reform" do
    check_reference("test/files/nombres-francais.txt", reformed: true)
  end

  test "reference file - pre reform" do
    check_reference("test/files/nombres-francais-pre-reforme.txt", reformed: false)
  end
end
