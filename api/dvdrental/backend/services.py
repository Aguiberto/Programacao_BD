from django.db import connection

# função criada no db aula 9
def customer_total_spent(customer_id):

    # estabelece uma conexão com o bando
    with connection.cursor() as cursor:
        cursor.execute("select get_customer_total_spent(%s)", [customer_id])

        # retorno de valor único fetch one
        return cursor.fetchone()[0]

def _fetch_all(query, params=None):
    with connection.cursor() as cursor:
        cursor.execute(query, params or [])
        columns = [column[0] for column in cursor.description]

def films_by_length(len_from, len_to):
    return _fetch_all(
        "select * get_film_by_length(%s::smallint, %s::smallint)",
        [len_from, len_to]
    )

def register_rental_with_payment(customer_id, inventory_id, staff_id, amount):

    with connection.cursor() as cursor:
        cursor.execute("call register_rental_with_payment(1::smallint, 1::smallint, 1::smallint, 5.99)
", [customer_id, inventory_id])
