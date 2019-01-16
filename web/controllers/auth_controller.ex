defmodule Discuss.AuthController do
    use Discuss.Web, :controller
    plug Ueberauth

    alias Discuss.User

    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
        # IO.puts "+++++++++++++++"
        # IO.inspect(conn.assigns.ueberauth_auth)
        # IO.inspect(auth)
        # IO.inspect(params)
        # IO.puts "+++++++++++++++"
        # IO.inspect(params)
        # IO.puts "+++++++++++++++"

        # Take returned information and save in the db
        user_params = %{token: auth.credentials.token, email: auth.info.email, provider: to_string(auth.provider)}
        changeset = User.changeset(%User{}, user_params)

        signin(conn, changeset)
    end

    defp signin(conn, changeset) do
        case insert_or_update_user(changeset) do 
            {:ok, user} -> 
                conn
                |> put_flash(:info, "Welcome back!")
                |> put_session(:user_id, user.id)
                |> redirect(to: topic_path(conn, :index))

            {:error, _reason} ->
                conn
                |> put_flash(:error, "Error signing in")
                |> redirect(to: topic_path(conn, :index))
        end
    end

    defp insert_or_update_user(changeset) do
        case Repo.get_by(User, email: changeset.changes.email) do 
            nil ->
                Repo.insert(changeset)
            user ->
                {:ok, user}
        end
    end

end