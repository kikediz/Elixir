defmodule TaskManager do
  def run(tasks \\ []) do
    IO.puts("1. Add task")
    IO.puts("2. List tasks")
    IO.puts("3. Complete task")
    IO.puts("4. Exit")

    case IO.gets("Choose an option: ") |> String.trim() |> String.to_integer() do
      1 ->
        description = IO.gets("Enter task description: ") |> String.trim()
        tasks = add_task(tasks, description)
        run(tasks)

      2 ->
        list_tasks(tasks)
        run(tasks)

      3 ->
        id = IO.gets("Enter task ID to complete: ") |> String.trim() |> String.to_integer()
        tasks = complete_task(tasks, id)
        run(tasks)

      4 ->
        IO.puts("Goodbye!")

      _ ->
        IO.puts("Invalid option")
        run(tasks)
    end
  end
end
