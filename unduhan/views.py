from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.utils import timezone
from django.db import connection
from django.contrib import messages

def query(sql, params=None):
    with connection.cursor() as cursor:
        cursor.execute(sql, params)
        if sql.strip().upper().startswith("SELECT"):
            columns = [col[0] for col in cursor.description]
            return [dict(zip(columns, row)) for row in cursor.fetchall()]
        else:
            return cursor.rowcount

def show_unduhan(request):
    # username = request.user.username
    username = 'carolyn64'

    query_str = '''
                SELECT t.id, t.judul, tt.timestamp 
                FROM tayangan t
                JOIN tayangan_terunduh tt ON t.id = tt.id_tayangan 
                WHERE tt.username = %s
                ORDER BY tt.timestamp DESC;
                '''
    hasil = query(query_str, [username])

    for data in hasil:
        data['formatted_timestamp'] = data['timestamp'].strftime("%Y-%m-%d %H:%M:%S")
    
    return render(request, 'daftar_unduhan.html', {'unduhan': hasil})

def remove_unduhan(request):
    if request.method == 'POST':
        id_tayangan = request.POST.get('id_tayangan')
        # username = request.user.username
        username = 'carolyn64'

        query_str = '''
                    SELECT timestamp 
                    FROM tayangan_terunduh 
                    WHERE id_tayangan = %s AND username = %s;
                    '''
        hasil = query(query_str, [id_tayangan, username])

        if hasil:
            timestamp = hasil[0]['timestamp']
            if timezone.is_naive(timestamp):
                timestamp = timezone.make_aware(timestamp, timezone.get_current_timezone())

            if timezone.now() - timestamp >= timezone.timedelta(days=1):
                query_str = '''
                            DELETE FROM tayangan_terunduh 
                            WHERE id_tayangan = %s AND username = %s;
                            '''
                query(query_str, [id_tayangan, username])
                messages.success(request, 'Tayangan berhasil dihapus dari daftar unduhan.')
            else:
                messages.error(request, 'Tayangan minimal harus berada di daftar unduhan selama 1 hari agar bisa dihapus.')
    
    return redirect('unduhan:show_unduhan')
