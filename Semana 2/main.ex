defmodule Library do
  @moduledoc """
  A module for managing a library system with books and users.
  """

  defmodule Book do
    @moduledoc """
    A struct representing a book in the library.
    """
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    @moduledoc """
    A struct representing a user of the library.
    """
    defstruct name: "", id: "", borrowed_books: []
  end

  @doc """
  Adds a book to the library.

  ## Parameters
  - library: The current list of books in the library.
  - book: The book struct to add.

  ## Examples

      iex> library = []
      iex> book = %Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}
      iex> Library.add_book(library, book)
      [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: true}]
  """
  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  @doc """
  Lists all books in the library.

  ## Parameters
  - library: The current list of books in the library.

  ## Examples

      iex> library = [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}]
      iex> Library.list_books(library)
      [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}]
  """
  def list_books(library) do
    library
  end

  @doc """
  Checks the availability of a book by its ISBN.

  ## Parameters
  - library: The current list of books in the library.
  - isbn: The ISBN of the book to check.

  ## Examples

      iex> library = [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: true}]
      iex> Library.book_available?(library, "1234567890")
      true
  """
  def book_available?(library, isbn) do
    Enum.any?(library, &(&1.isbn == isbn && &1.available))
  end

  @doc """
  Adds a user to the library system.

  ## Parameters
  - users: The current list of users.
  - user: The user struct to add.

  ## Examples

      iex> users = []
      iex> user = %Library.User{name: "Alice", id: "1"}
      iex> Library.add_user(users, user)
      [%Library.User{name: "Alice", id: "1", borrowed_books: []}]
  """
  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  @doc """
  Lists all users in the library system.

  ## Parameters
  - users: The current list of users.

  ## Examples

      iex> users = [%Library.User{name: "Alice", id: "1"}]
      iex> Library.list_users(users)
      [%Library.User{name: "Alice", id: "1"}]
  """
  def list_users(users) do
    users
  end

  @doc """
  Allows a user to borrow a book from the library.

  ## Parameters
  - library: The current list of books in the library.
  - users: The current list of users.
  - user_id: The ID of the user borrowing the book.
  - isbn: The ISBN of the book to borrow.

  ## Examples

      iex> library = [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: true}]
      iex> users = [%Library.User{name: "Alice", id: "1", borrowed_books: []}]
      iex> Library.borrow_book(library, users, "1", "1234567890")
      {:ok, [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: false}], [%Library.User{name: "Alice", id: "1", borrowed_books: [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: false}]}]}
  """
  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  @doc """
  Allows a user to return a borrowed book to the library.

  ## Parameters
  - library: The current list of books in the library.
  - users: The current list of users.
  - user_id: The ID of the user returning the book.
  - isbn: The ISBN of the book to return.

  ## Examples

      iex> library = [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: false}]
      iex> users = [%Library.User{name: "Alice", id: "1", borrowed_books: [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: false}]}]
      iex> Library.return_book(library, users, "1", "1234567890")
      {:ok, [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: true}], [%Library.User{name: "Alice", id: "1", borrowed_books: []}]}
  """
  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  @doc """
  Lists all books borrowed by a specific user.

  ## Parameters
  - users: The current list of users.
  - user_id: The ID of the user whose borrowed books are to be listed.

  ## Examples

      iex> users = [%Library.User{name: "Alice", id: "1", borrowed_books: [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}]}]
      iex> Library.books_borrowed_by_user(users, "1")
      [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}]
  """
  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  def run do
    library = []
    users = []

    loop(library, users)
  end

  defp loop(library, users) do
    IO.puts("""
    1. Add book
    2. List books
    3. Add user
    4. List users
    5. Borrow book
    6. Return book
    7. Exit
    """)

    case IO.gets("Choose an option: ") |> String.trim() |> String.to_integer() do
      1 ->
        library = add_book_prompt(library)
        loop(library, users)

      2 ->
        list_books(library) |> Enum.each(&IO.inspect/1)
        loop(library, users)

      3 ->
        users = add_user_prompt(users)
        loop(library, users)

      4 ->
        list_users(users) |> Enum.each(&IO.inspect/1)
        loop(library, users)

      5 ->
        {library, users} = borrow_book_prompt(library, users)
        loop(library, users)

      6 ->
        {library, users} = return_book_prompt(library, users)
        loop(library, users)

      7 ->
        IO.puts("Goodbye!")

      _ ->
        IO.puts("Invalid option")
        loop(library, users)
    end
  end

  # Funciones de ayuda para el menú
  defp add_book_prompt(library) do
    title = IO.gets("Enter book title: ") |> String.trim()
    author = IO.gets("Enter book author: ") |> String.trim()
    isbn = IO.gets("Enter book ISBN: ") |> String.trim()
    book = %Book{title: title, author: author, isbn: isbn}
    add_book(library, book)
  end

  defp add_user_prompt(users) do
    name = IO.gets("Enter user name: ") |> String.trim()
    id = IO.gets("Enter user ID: ") |> String.trim()
    user = %User{name: name, id: id}
    add_user(users, user)
  end

  defp borrow_book_prompt(library, users) do
    user_id = IO.gets("Enter user ID: ") |> String.trim()
    isbn = IO.gets("Enter book ISBN: ") |> String.trim()
    case borrow_book(library, users, user_id, isbn) do
      {:ok, new_library, new_users} -> {new_library, new_users}
      {:error, message} ->
        IO.puts(message)
        {library, users}
    end
  end

  defp return_book_prompt(library, users) do
    user_id = IO.gets("Enter user ID: ") |> String.trim()
    isbn = IO.gets("Enter book ISBN: ") |> String.trim()
    case return_book(library, users, user_id, isbn) do
      {:ok, new_library, new_users} -> {new_library, new_users}
      {:error, message} ->
        IO.puts(message)
        {library, users}
    end
  end
end

Library.run()
