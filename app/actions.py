import psycopg2
from psycopg2.extras import RealDictCursor

# Database connection parameter configuration
CONN_STRING = "dbname=lab_db user=postgres password=postgres host=127.0.0.1 port=5432"


def get_connection():
    return psycopg2.connect(CONN_STRING)


def save_user(first_name: str, last_name: str, phone: str, id_card: str) -> int:

    sql = "SELECT save_users(%s, %s, %s, %s);"
    
    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql, (first_name, last_name, phone, id_card))
            result = cursor.fetchone()
            conn.commit()
            return result[0] if result else None


def check_exists(id_card: str) -> bool:

    sql = "SELECT COUNT(1) FROM users WHERE id_card_num = %s;"
    
    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql, (id_card,))
            count = cursor.fetchone()[0]
            return count > 0


def delete_tier(tier_id: int) -> tuple[bool, str]:

    sql = "SELECT delete_tiers(%s);"
    
    try:
        with get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql, (tier_id,))
                conn.commit()
                return True, ""
    except psycopg2.Error as ex:
        # Captures RAISE EXCEPTION messages thrown by PL/pgSQL
        return False, ex.pgerror or str(ex)


def filter_users(search_text: str) -> list[tuple]:

    sql = """
        SELECT user_id, first_name, last_name, phone_number, id_card_num
        FROM users
        WHERE LOWER(first_name) LIKE LOWER(%s)
           OR LOWER(last_name) LIKE LOWER(%s)
           OR LOWER(id_card_num) LIKE LOWER(%s);
    """
    search_pattern = f"%{search_text}%"
    
    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql, (search_pattern, search_pattern, search_pattern))
            return cursor.fetchall()


def get_parent_list() -> list[tuple[int, str]]:
    sql = "SELECT user_id, first_name || ' ' || last_name || ' (' || id_card_num || ')' FROM users;"
    
    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(sql)
            return cursor.fetchall()