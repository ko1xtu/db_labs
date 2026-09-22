using System;
using System.Collections.Generic;
using Npgsql;

public class DatabaseRepository
{
    private readonly string _connectionString;

    public DatabaseRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    // 1. Loads parent table records for foreign key dropdown selectors
    public List<KeyValuePair<long, string>> GetParentList()
    {
        var result = new List<KeyValuePair<long, string>>();

        using (var conn = new NpgsqlConnection(_connectionString))
        {
            conn.Open();
            string sql = "SELECT user_id, first_name || ' ' || last_name || ' (' || id_card_num || ')' FROM users";

            using (var cmd = new NpgsqlCommand(sql, conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    result.Add(new KeyValuePair<long, string>(
                        reader.GetInt64(0),
                        reader.GetString(1)
                    ));
                }
            }
        }

        return result;
    }

    // 2. Case-insensitive filtering via SQL query
    public List<string[]> FilterRecords(string searchText)
    {
        var records = new List<string[]>();

        using (var conn = new NpgsqlConnection(_connectionString))
        {
            conn.Open();
            string sql = @"SELECT user_id, first_name, last_name, phone_number, id_card_num 
                           FROM users 
                           WHERE LOWER(first_name) LIKE LOWER(@search) 
                              OR LOWER(last_name) LIKE LOWER(@search)
                              OR LOWER(id_card_num) LIKE LOWER(@search)";

            using (var cmd = new NpgsqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("search", $"%{searchText}%");

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        records.Add(new string[]
                        {
                            reader.GetInt64(0).ToString(),
                            reader.GetString(1),
                            reader.GetString(2),
                            reader.GetString(3),
                            reader.GetString(4)
                        });
                    }
                }
            }
        }

        return records;
    }

    // 3. Checks whether a record already exists before saving
    public bool CheckExists(string idCardNum)
    {
        using (var conn = new NpgsqlConnection(_connectionString))
        {
            conn.Open();
            string sql = "SELECT COUNT(1) FROM users WHERE id_card_num = @idc";

            using (var cmd = new NpgsqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("idc", idCardNum);
                long count = Convert.ToInt64(cmd.ExecuteScalar());
                return count > 0;
            }
        }
    }

    // 4. Calls PL/pgSQL function to insert or update user records
    public long SaveRecord(string firstName, string lastName, string phoneNumber, string idCardNum)
    {
        using (var conn = new NpgsqlConnection(_connectionString))
        {
            conn.Open();
            using (var cmd = new NpgsqlCommand("SELECT save_users(@fn, @ln, @pn, @idc)", conn))
            {
                cmd.Parameters.AddWithValue("fn", firstName);
                cmd.Parameters.AddWithValue("ln", lastName);
                cmd.Parameters.AddWithValue("pn", phoneNumber);
                cmd.Parameters.AddWithValue("idc", idCardNum);

                return Convert.ToInt64(cmd.ExecuteScalar());
            }
        }
    }

    // 5. Calls PL/pgSQL function to delete tier records with constraint error handling
    public bool DeleteRecord(int tierId, out string errorMessage)
    {
        errorMessage = string.Empty;

        try
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                using (var cmd = new NpgsqlCommand("SELECT delete_tiers(@id)", conn))
                {
                    cmd.Parameters.AddWithValue("id", tierId);
                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
        }
        catch (PostgresException ex)
        {
            errorMessage = ex.MessageText;
            return false;
        }
    }
}