databse_connection = dbConnect("mysql", "testing_env", "testing_env", "testing_env")

function get_db()
    return databse_connection
end
