defmodule InventoryManager do
  defstruct inventory: [], cart: [], next_id: 1

  def run(state \\ %InventoryManager{}) do
    IO.puts("1. Agregar producto")
    IO.puts("2. Listar productos")
    IO.puts("3. Incrementar inventario")
    IO.puts("4. Vender producto")
    IO.puts("5. Ver carrito")
    IO.puts("6. Pagar y vaciar carrito")
    IO.puts("7. Salir")

    case IO.gets("Escoge una opción: ") |> String.trim() |> String.to_integer() do
      1 ->
        name = IO.gets("Ingresa el nombre del producto: ") |> String.trim()
        price = IO.gets("Ingresa el precio del producto: ") |> String.trim() |> parse_float()
        stock = IO.gets("Ingresa el inventario existente del producto: ") |> String.trim() |> String.to_integer()
        state = add_product(state, name, price, stock)
        run(state)

      2 ->
        list_products(state.inventory)
        run(state)

      3 ->
        id = IO.gets("Ingresa el ID del producto para incrementar el inventario: ") |> String.trim() |> String.to_integer()
        quantity = IO.gets("Ingresa la cantidad a agregar: ") |> String.trim() |> String.to_integer()
        state = increase_stock(state, id, quantity)
        run(state)

      4 ->
        id = IO.gets("Ingresa el ID del producto a vender: ") |> String.trim() |> String.to_integer()
        quantity = IO.gets("Ingresa la cantidad a vender: ") |> String.trim() |> String.to_integer()
        state = sell_product(state, id, quantity)
        run(state)

      5 ->
        view_cart(state.cart)
        run(state)

      6 ->
        state = checkout(state)
        run(state)

      7 ->
        IO.puts("Adiós!")

      _ ->
        IO.puts("Opción inválida")
        run(state)
    end
  end

  defp parse_float(input) do
    case Float.parse(input) do
      {value, _} -> value
      :error -> IO.puts("Entrada flotante invalida"); 0.0
    end
  end

  defp add_product(%InventoryManager{inventory: inventory, next_id: next_id} = state, name, price, stock) do
    product = %{id: next_id, name: name, price: price, stock: stock}
    %{state | inventory: [product | inventory], next_id: next_id + 1}
  end

  defp list_products(inventory) do
    Enum.each(inventory, fn product ->
      IO.puts("ID: #{product.id}, Nombre: #{product.name}, Precio: #{product.price}, Stock: #{product.stock}")
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
      IO.puts("Insuficiente stock o ID de producto inválido")
      state
    end
  end

  defp view_cart(cart) do
    Enum.each(cart, fn {id, quantity} ->
      IO.puts("Producto ID: #{id}, Cantidad: #{quantity}")
    end)
  end

  defp checkout(%InventoryManager{cart: cart} = state) do
    total = Enum.reduce(cart, 0, fn {id, quantity}, acc ->
      product = Enum.find(state.inventory, fn product -> product.id == id end)
      acc + product.price * quantity
    end)
    IO.puts("Total: #{total}")
    %{state | cart: []}
  end
end

InventoryManager.run()
