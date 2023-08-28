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
    {
      length(champ),
      Enum.map(champ, &count_player/1) |> Enum.sum(),
      Enum.sum(Enum.map(champ, &get_average_age/1)) / length(champ),
      Enum.sum(Enum.map(champ, &get_average_rating/1)) / length(champ)
    }
  end

  def count_player({:team, _name, players}) do
    length(players)
  end

  def get_average_age({:team, _name, players} = team) do
    total_age = Enum.sum(Enum.map(players, fn {:player, _, age, _, _} -> age end))
    total_age / count_player(team)
  end

  def get_average_rating({:team, _name, players} = team) do
    total_rating = Enum.sum(Enum.map(players, fn {:player, _, _, rating, _} -> rating end))
    total_rating / count_player(team)
  end

  def examine_champ(champ) do
    champ
    |> Enum.map(&filter_weak_players/1)
    |> Enum.filter(fn team -> count_player(team) >= 5 end)
  end

  def filter_weak_players({:team, name, players}) do
    f = fn {:player, _, _, _, health} -> health >= 50 end
    healthy_players = Enum.filter(players, f)
    {:team, name, healthy_players}
  end

  def make_pairs(team1, team2) do
    {:team, team_name1, players1} = team1
    {:team, team_name2, players2} = team2

    p1 =
      players1 |> Enum.map(fn {:player, name, _, rating, _} -> {name, rating, team_name1} end)

    p2 =
      players2 |> Enum.map(fn {:player, name, _, rating, _} -> {name, rating, team_name2} end)

    for {n1, r1, t1} <- p1, {n2, r2, t2} <- p2, r1 + r2 > 600, do: {n1, n2}
  end
end

