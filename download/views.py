from django.shortcuts import render, redirect
from django.views.decorators.http import require_http_methods
from django.utils.timezone import now
from utils.query import get_db_connection
from django.http import JsonResponse

def index(request):
    username = request.session.get('username')
    if not username:
        return redirect('authentication:logout')

    shows = get_downloaded_shows(username)
    available_shows = get_available_shows(username)
    context = {
        'shows': shows,
        'available_shows': available_shows,
        'selected_show': None,
        'expiration_date': None,
        'is_logged_in': True,
        'username': username
    }
    return render(request, 'index.html', context)

def get_downloaded_shows(username):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute(
        "SELECT TAYANGAN.judul, TAYANGAN_TERUNDUH.timestamp, TAYANGAN_TERUNDUH.id_tayangan "
        "FROM TAYANGAN_TERUNDUH "
        "JOIN TAYANGAN ON TAYANGAN.id = TAYANGAN_TERUNDUH.id_tayangan "
        "WHERE TAYANGAN_TERUNDUH.username = %s",
        (username,)
    )
    rows = cursor.fetchall()
    cursor.close()
    connection.close()

    shows = [{'judul': row[0], 'timestamp': row[1], 'id_tayangan': row[2]} for row in rows]
    return shows

def get_available_shows(username):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute(
        "SELECT TAYANGAN.id, TAYANGAN.judul "
        "FROM TAYANGAN "
        "WHERE TAYANGAN.id NOT IN (SELECT id_tayangan FROM TAYANGAN_TERUNDUH WHERE username = %s)",
        (username,)
    )
    rows = cursor.fetchall()
    cursor.close()
    connection.close()

    shows = [{'id': row[0], 'judul': row[1]} for row in rows]
    return shows

def delete_downloaded_show(username, show_id):
    connection = get_db_connection()
    cursor = connection.cursor()
    try:
        cursor.execute(
            "DELETE FROM TAYANGAN_TERUNDUH WHERE username = %s AND id_tayangan = %s",
            (username, show_id)
        )
        connection.commit()
        return True
    except Exception as e:
        print("Penghapusan gagal:", e)
        return False
    finally:
        cursor.close()
        connection.close()

def add_download(username, show_id):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute(
        "INSERT INTO TAYANGAN_TERUNDUH (username, id_tayangan, timestamp) VALUES (%s, %s, %s)",
        (username, show_id, now())
    )
    connection.commit()
    cursor.close()
    connection.close()

@require_http_methods(['POST'])
def add_download_view(request):
    username = request.session.get('username')
    if not username:
        return JsonResponse({'success': False, 'error': 'User not logged in'})

    show_id = request.POST.get('show_id')
    add_download(username, show_id)
    return JsonResponse({'success': True})

@require_http_methods(['POST'])
def delete_show(request):
    username = request.session.get('username')
    if not username:
        return JsonResponse({'success': False, 'error': 'User not logged in'})

    show_id = request.POST.get('show_id')
    try:
        if delete_downloaded_show(username, show_id):
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'success': False, 'error': 'Tayangan tidak bisa dihapus, masih kurang dari 1 hari sejak diunduh.'})
    except Exception as e:
        return JsonResponse({'success': False, 'error': str(e)})