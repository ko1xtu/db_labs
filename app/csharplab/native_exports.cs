using System;
using System.Runtime.InteropServices;
using Npgsql;

public static class NativeExports
{
    private const string ConnString =
        "Host=127.0.0.1;Port=5432;Database=lab_db;Username=postgres;Password=postgres";

    private static readonly DatabaseRepository Repo = new(ConnString);

    [UnmanagedCallersOnly(EntryPoint = "save_user_native")]
    public static long SaveUserNative(IntPtr fn, IntPtr ln, IntPtr pn, IntPtr idc)
    {
        try
        {
            return Repo.SaveRecord(
                Marshal.PtrToStringUTF8(fn) ?? "",
                Marshal.PtrToStringUTF8(ln) ?? "",
                Marshal.PtrToStringUTF8(pn) ?? "",
                Marshal.PtrToStringUTF8(idc) ?? ""
            );
        }
        catch
        {
            return 0;
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "check_exists_native")]
    public static int CheckExistsNative(IntPtr idc)
    {
        try
        {
            return Repo.CheckExists(Marshal.PtrToStringUTF8(idc) ?? "") ? 1 : 0;
        }
        catch
        {
            return 0;
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "delete_tier_native")]
    public static int DeleteTierNative(int tierId)
    {
        try
        {
            return Repo.DeleteRecord(tierId, out _) ? 1 : 0;
        }
        catch
        {
            return 0;
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "delete_user_native")]
    public static int DeleteUserNative(long userId)
    {
        try
        {
            using var conn = new NpgsqlConnection(ConnString);
            conn.Open();
            using var cmd = new NpgsqlCommand("DELETE FROM users WHERE user_id = @id", conn);
            cmd.Parameters.AddWithValue("id", userId);
            cmd.ExecuteNonQuery();
            return 1;
        }
        catch
        {
            return 0;
        }
    }
}