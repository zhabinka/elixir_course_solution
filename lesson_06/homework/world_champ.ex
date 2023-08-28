defmodule WorldChamp do
  def sample_champ() do
    [
      {
        :team,
        "Crazy Bulls",
        [
          {:player, "Big Bull", 22, 545, 99},
          {:player, "Small Bull", 18, 324, 95},
          {:player, "Bull Bob", 19, 32, 45},
          {:player, "Bill The Bull", 23, 132, 85},
          {:player, "Tall Ball Bull", 38, 50, 50},
          {:player, "Bull Dog", 35, 201, 91},
          {:player, "Bull Tool", 29, 77, 96},
          {:player, "Mighty Bull", 22, 145, 98}
        ]
      },
      {
        :team,
        "Cool Horses",
        [
          {:player, "Lazy Horse", 21, 423, 80},
          {:player, "Sleepy Horse", 23, 101, 35},
          {:player, "Horse Doors", 19, 87, 23},
          {:player, "Rainbow", 21, 200, 17},
          {:player, "HoHoHorse", 20, 182, 44},
          {:player, "Pony", 25, 96, 76},
          {:player, "Hippo", 17, 111, 96},
          {:player, "Hop-Hop", 31, 124, 49}
        ]
      },
      {
        :team,
        "Fast Cows",
        [
          {:player, "Flash Cow", 18, 56, 34},
          {:player, "Cow Bow", 28, 89, 90},
          {:player, "Boom! Cow", 20, 131, 99},
          {:player, "Light Speed Cow", 21, 201, 98},
          {:player, "Big Horn", 23, 38, 93},
          {:player, "Milky", 25, 92, 95},
          {:player, "Jumping Cow", 19, 400, 98},
          {:player, "Cow Flow", 18, 328, 47}
        ]
      },
      {
        :team,
        "Fury Hens",
        [
          {:player, "Ben The Hen", 57, 403, 83},
          {:player, "Hen Hen", 20, 301, 56},
          {:player, "Son of Hen", 21, 499, 43},
          {:player, "Beak", 22, 35, 96},
          {:player, "Superhen", 27, 12, 26},
          {:player, "Henman", 20, 76, 38},
          {:player, "Farm Hen", 18, 131, 47},
          {:player, "Henwood", 40, 198, 77}
        ]
      },
      {
        :team,
        "Extinct Monsters",
        [
          {:player, "T-Rex", 21, 999, 99},
          {:player, "Velociraptor", 29, 656, 99},
          {:player, "Giant Mammoth", 30, 382, 99},
          {:player, "The Big Croc", 42, 632, 99},
          {:player, "Huge Pig", 18, 125, 98},
          {:player, "Saber-Tooth", 19, 767, 97},
          {:player, "Beer Bear", 24, 241, 99},
          {:player, "Pure Horror", 31, 90, 43}
        ]
      }
    ]
  end

  def get_stat(champ) do
    players = get_players(champ)

    {
      length(champ),
      length(players),
      get_average_age(players),
      get_average_rating(players)
    }
  end

  def get_players(champ) do
    champ
    |> Enum.reduce([], fn {:team, _, players}, acc -> acc ++ players end)
  end

  def get_average_age(players) do
    total_age = Enum.reduce(players, 0, fn {:player, _, age, _, _}, acc -> acc + age end)
    total_age / length(players)
  end

  def get_average_rating(players) do
    total_rating = Enum.reduce(players, 0, fn {:player, _, _, rating, _}, acc -> acc + rating end)
    total_rating / length(players)
  end

  def examine_champ(champ) do
    champ
    |> Enum.map(&filter_weak_players/1)
    |> Enum.filter(fn {:team, _, players} -> length(players) >= 5 end)
  end

  def filter_weak_players({:team, name, players}) do
    filter = fn {:player, _, _, _, health} -> health >= 50 end
    healthy_players = Enum.filter(players, filter)
    {:team, name, healthy_players}
  end

  def make_pairs(team1, team2) do
    {:team, _, players1} = team1
    {:team, _, players2} = team2

    for {:player, name1, _, rating1, _} <- players1,
        {:player, name2, _, rating2, _} <- players2,
        rating1 + rating2 > 600,
        do: {name1, name2}
  end
end
