defmodule InventoryManager do
  defstruct inventory: [], cart: [], next_id: 1

  def run(state \\ %InventoryManager{}) do
    IO.puts("1. Add product")
    IO.puts("2. List products")
    IO.puts("3. Increase stock")
    IO.puts("4. Sell product")
    IO.puts("5. View cart")
    IO.puts("6. Checkout")
    IO.puts("7. Exit")

    case IO.gets("Choose an option: ") |> String.trim() |> String.to_integer() do
      1 ->
        name = IO.gets("Enter product name: ") |> String.trim()
        price = IO.gets("Enter product price: ") |> String.trim() |> String.to_float()
        stock = IO.gets("Enter product stock: ") |> String.trim() |> String.to_integer()
        state = add_product(state, name, price, stock)
        run(state)

      2 ->
        list_products(state.inventory)
        run(state)

      3 ->
        id = IO.gets("Enter product ID to increase stock: ") |> String.trim() |> String.to_integer()
        quantity = IO.gets("Enter quantity to add: ") |> String.trim() |> String.to_integer()
        state = increase_stock(state, id, quantity)
        run(state)

      4 ->
        id = IO.gets("Enter product ID to sell: ") |> String.trim() |> String.to_integer()
        quantity = IO.gets("Enter quantity to sell: ") |> String.trim() |> String.to_integer()
        state = sell_product(state, id, quantity)
        run(state)

      5 ->
        view_cart(state.cart)
        run(state)

      6 ->
        state = checkout(state)
        run(state)

      7 ->
        IO.puts("Goodbye!")

      _ ->
        IO.puts("Invalid option")
        run(state)
    end
  end

  defp add_product(%InventoryManager{inventory: inventory, next_id: next_id} = state, name, price, stock) do
    product = %{id: next_id, name: name, price: price, stock: stock}
    %{state | inventory: [product | inventory], next_id: next_id + 1}
  end

  defp list_products(inventory) do
    Enum.each(inventory, fn product ->
      IO.puts("ID: #{product.id}, Name: #{product.name}, Price: #{product.price}, Stock: #{product.stock}")
    end)
  end

  defp increase_stock(%InventoryManager{inventory: inventory} = state, id, quantity) do
    updated_inventory = Enum.map(inventory, fn product ->
      if product.id == id do
        %{product | stock: product.stock + quantity}
      else
        product
      end
    end)
    %{state | inventory: updated_inventory}
  end

  defp sell_product(%InventoryManager{inventory: inventory, cart: cart} = state, id, quantity) do
    {product, updated_inventory} = Enum.split_with(inventory, fn product -> product.id == id end)
    if product != [] and hd(product).stock >= quantity do
      updated_product = %{hd(product) | stock: hd(product).stock - quantity}
      updated_cart = [{id, quantity} | cart]
      %{state | inventory: [updated_product | updated_inventory], cart: updated_cart}
    else
      IO.puts("Insufficient stock or invalid product ID")
      state
    end
  end

  defp view_cart(cart) do
    Enum.each(cart, fn {id, quantity} ->
      IO.puts("Product ID: #{id}, Quantity: #{quantity}")
    end)
  end

  defp checkout(%InventoryManager{cart: cart} = state) do
    total = Enum.reduce(cart, 0, fn {id, quantity}, acc ->
      product = Enum.find(state.inventory, fn product -> product.id == id end)
      acc + product.price * quantity
    end)
    IO.puts("Total amount: #{total}")
    %{state | cart: []}
  end
end