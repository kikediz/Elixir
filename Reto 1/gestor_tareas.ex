defmodule TaskManager do
  def run(tasks \\ []) do
    IO.puts("1. Agregar tarea")
    IO.puts("2. Listar tareas")
    IO.puts("3. Completar tareas")
    IO.puts("4. Salir!")

    case IO.gets("Selecciona una opción: ") |> String.trim() |> String.to_integer() do
      1 ->
        description = IO.gets("Ingresar la description de la tarea: ") |> String.trim()
        tasks = add_task(tasks, description)
        run(tasks)

      2 ->
        list_tasks(tasks)
        run(tasks)

      3 ->
        id = IO.gets("Ingresa el ID de la tarea a completar: ") |> String.trim() |> String.to_integer()
        tasks = complete_task(tasks, id)
        run(tasks)

      4 ->
        IO.puts("Adiós!")

      _ ->
        IO.puts("Invalid option")
        run(tasks)
    end
  end

  defp add_task(tasks, description) do
    id = length(tasks) + 1
    task = %{id: id, description: description, completed: false}
    [task | tasks]
  end

  defp list_tasks(tasks) do
    Enum.each(tasks, fn task ->
      IO.puts("#{task.id}. [#{if task.completed, do: "X", else: " "}] #{task.description}")
    end)
  end

  defp complete_task(tasks, id) do
    Enum.map(tasks, fn task ->
      if task.id == id do
        %{task | completed: true}
      else
        task
      end
    end)
  end
end

TaskManager.run()
