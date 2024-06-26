defmodule Scholar.Neighbors.KDTreeTest do
  use ExUnit.Case, async: true
  alias Scholar.Neighbors.KDTree
  doctest KDTree

  defp example do
    Nx.tensor([
      [10, 15],
      [46, 63],
      [68, 21],
      [40, 33],
      [25, 54],
      [15, 43],
      [44, 58],
      [45, 40],
      [62, 69],
      [53, 67]
    ])
  end

  describe "fit" do
    test "iota" do
      assert %KDTree{levels: 3, indices: indices} = KDTree.fit(Nx.iota({5, 2}))
      assert indices == Nx.u32([3, 1, 4, 0, 2])
    end

    test "float" do
      assert %KDTree{levels: 4, indices: indices} = KDTree.fit(example() |> Nx.as_type(:f32))
      assert Nx.to_flat_list(indices) == [1, 5, 9, 3, 6, 2, 8, 0, 7, 4]
    end

    test "sample" do
      assert %KDTree{levels: 4, indices: indices} = KDTree.fit(example())
      assert Nx.to_flat_list(indices) == [1, 5, 9, 3, 6, 2, 8, 0, 7, 4]
    end
  end

  defp x do
    Nx.tensor([
      [3, 6, 7, 5],
      [9, 8, 5, 4],
      [4, 4, 4, 1],
      [9, 4, 5, 6],
      [6, 4, 5, 7],
      [4, 5, 3, 3],
      [4, 5, 7, 8],
      [9, 4, 4, 5],
      [8, 4, 3, 9],
      [2, 8, 4, 4]
    ])
  end

  defp x_pred do
    Nx.tensor([[4, 3, 8, 4], [1, 6, 1, 1], [3, 7, 9, 2], [5, 2, 1, 2]])
  end

  describe "predict knn" do
    test "all defaults" do
      kdtree = KDTree.fit(x())

      assert KDTree.predict(kdtree, x_pred()) ==
               Nx.tensor([[0, 6, 4], [5, 2, 9], [0, 9, 2], [5, 2, 7]])
    end

    test "metric set to {:minkowski, 1.5}" do
      kdtree = KDTree.fit(x())

      assert KDTree.predict(kdtree, x_pred(), metric: {:minkowski, 1.5}) ==
               Nx.tensor([[0, 6, 2], [5, 2, 9], [0, 9, 2], [5, 2, 7]])
    end

    test "k set to 4" do
      kdtree = KDTree.fit(x())

      assert KDTree.predict(kdtree, x_pred(), k: 4) ==
               Nx.tensor([[0, 6, 4, 2], [5, 2, 9, 0], [0, 9, 2, 5], [5, 2, 7, 4]])
    end

    test "float type data" do
      kdtree = KDTree.fit(x() |> Nx.as_type(:f64))

      assert KDTree.predict(kdtree, x_pred(), k: 4) ==
               Nx.tensor([[0, 6, 4, 2], [5, 2, 9, 0], [0, 9, 2, 5], [5, 2, 7, 4]])
    end
  end
end
