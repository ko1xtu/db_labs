import ctypes
import os
import psycopg2
from psycopg2.extras import RealDictCursor


# --- CONFIGURATION & MODE SWITCH ---
BACKEND_MODE = "сsharp"  # Supported values: "python" or "csharp"
CONN_STRING = "dbname=lab_db user=postgres password=postgres host=127.0.0.1 port=5432"

# --- LOAD C# NATIVE LIBRARY ---
CSHARP_LIB_PATH = os.path.abspath(
    "csharplab/bin/Release/net10.0/linux-x64/publish/actions.so"
)
csharp_lib = None

if os.path.exists(CSHARP_LIB_PATH):
    try:
        csharp_lib = ctypes.CDLL(CSHARP_LIB_PATH)
        
        # Configure C# Native function signatures
        csharp_lib.save_user_native.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p]
        csharp_lib.save_user_native.restype = ctypes.c_int64

        csharp_lib.check_exists_native.argtypes = [ctypes.c_char_p]
        csharp_lib.check_exists_native.restype = ctypes.c_int

        csharp_lib.delete_tier_native.argtypes = [ctypes.c_int32]
        csharp_lib.delete_tier_native.restype = ctypes.c_int

        csharp_lib.delete_user_native.argtypes = [ctypes.c_int64]
        csharp_lib.delete_user_native.restype = ctypes.c_int
    except Exception as e:
        print(f"Warning: Could not load C# binary library: {e}")


def set_backend_mode(mode: str):
    """Switch the execution engine between 'python' and 'csharp' dynamically."""
    global BACKEND_MODE
    if mode.lower() in ["python", "csharp"]:
        if mode.lower() == "csharp" and not csharp_lib:
            raise RuntimeError("C# shared object library is not loaded or missing.")
        BACKEND_MODE = mode.lower()
        print(f"Active Backend Switched To: {BACKEND_MODE.upper()}")
    else:
        raise ValueError("Invalid mode. Choose 'python' or 'csharp'.")


# --- PYTHON PSYCOPG2 BACKEND ---
def _get_connection():
    return psycopg2.connect(CONN_STRING)


# --- UNIFIED API METHODS ---
def save_user(first_name: str, last_name: str, phone: str, id_card: str) -> int:
    if BACKEND_MODE == "csharp":
        return csharp_lib.save_user_native(
            first_name.encode("utf-8"),
            last_name.encode("utf-8"),
            phone.encode("utf-8"),
            id_card.encode("utf-8")
        )
    
    # Python fallback implementation
    sql = "SELECT save_users(%s, %s, %s, %s);"
    with _get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql, (first_name, last_name, phone, id_card))
            result = cursor.fetchone()
            conn.commit()
            return result[0] if result else None


def check_exists(id_card: str) -> bool:
    if BACKEND_MODE == "csharp":
        return bool(csharp_lib.check_exists_native(id_card.encode("utf-8")))

    # Python fallback implementation
    sql = "SELECT COUNT(1) FROM users WHERE id_card_num = %s;"
    with _get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql, (id_card,))
            count = cursor.fetchone()[0]
            return count > 0


def delete_tier(tier_id: int) -> tuple[bool, str]:
    if BACKEND_MODE == "csharp":
        status = csharp_lib.delete_tier_native(tier_id)
        return (True, "") if status == 1 else (False, "Error executing C# delete operation.")

    # Python fallback implementation
    sql = "SELECT delete_tiers(%s);"
    try:
        with _get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql, (tier_id,))
                conn.commit()
                return True, ""
    except psycopg2.Error as ex:
        return False, ex.pgerror or str(ex)


def delete_user(user_id: int) -> tuple[bool, str]:
    if BACKEND_MODE == "csharp":
        status = csharp_lib.delete_user_native(user_id)
        return (True, "") if status == 1 else (False, "Error executing C# delete operation.")

    # Python fallback implementation
    sql = "DELETE FROM users WHERE user_id = %s;"
    try:
        with _get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql, (user_id,))
                conn.commit()
                return True, ""
    except psycopg2.Error as ex:
        return False, ex.pgerror or str(ex)


def filter_users(search_text: str) -> list[tuple]:
    """Database-level case-insensitive filtering."""
    sql = """
        SELECT user_id, first_name, last_name, phone_number, id_card_num
        FROM users
        WHERE LOWER(first_name) LIKE LOWER(%s)
           OR LOWER(last_name) LIKE LOWER(%s)
           OR LOWER(id_card_num) LIKE LOWER(%s);
    """
    search_pattern = f"%{search_text}%"
    with _get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql, (search_pattern, search_pattern, search_pattern))
            return cursor.fetchall()


def get_parent_list() -> list[tuple[int, str]]:
    """Populates foreign key dropdown menus."""
    sql = "SELECT user_id, first_name || ' ' || last_name || ' (' || id_card_num || ')' FROM users;"
    with _get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql)
            return cursor.fetchall()