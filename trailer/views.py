from django.db import connection
from django.shortcuts import render

def show_trailers(request):
    context = {
        "is_logged_in": False
    }
    if "username" in request.session:
        context["is_logged_in"] = True
        context["username"] = request.session["username"]

    # Query for trailers from the pacilflix.tayangan table
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                t.judul AS title,
                t.sinopsis_trailer AS synopsis,
                t.url_video_trailer AS trailer_url,
                t.release_date_trailer AS release_date
            FROM
                pacilflix.tayangan t
            WHERE
                t.url_video_trailer IS NOT NULL
        """)
        trailers = [
            {
                'title': row[0],
                'synopsis': row[1],
                'trailer_url': row[2],
                'release_date': row[3]
            }
            for row in cursor.fetchall()
        ]

    # Query for films
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                t.judul AS title,
                t.sinopsis_trailer AS synopsis,
                t.url_video_trailer AS trailer_url,
                f.release_date_film AS release_date
            FROM 
                pacilflix.film f
                JOIN pacilflix.tayangan t ON f.id_tayangan = t.id
        """)
        film_list = [
            {
                'title': row[0],
                'synopsis': row[1],
                'trailer_url': row[2],
                'release_date': row[3],
            }
            for row in cursor.fetchall()
        ]

    # Query for series
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                t.judul AS title,
                t.sinopsis_trailer AS synopsis,
                t.url_video_trailer AS trailer_url,
                t.release_date_trailer AS release_date
            FROM 
                pacilflix.series s
                JOIN pacilflix.tayangan t ON s.id_tayangan = t.id
        """)
        series_list = [
            {
                'title': row[0],
                'synopsis': row[1],
                'trailer_url': row[2],
                'release_date': row[3],
            }
            for row in cursor.fetchall()
        ]

    context.update({
        'trailers': trailers,
        'film_list': film_list,
        'series_list': series_list
    })
    return render(request, "trailer.html", context)

def show_trailer_search(request):
    query = request.GET.get('q', '')
    context = {'query': query}

    if query:
        with connection.cursor() as cursor:
            # Search for trailers
            cursor.execute("""
                SELECT
                    t.judul AS title,
                    t.sinopsis_trailer AS synopsis,
                    t.url_video_trailer AS trailer_url,
                    t.release_date_trailer AS release_date
                FROM
                    pacilflix.tayangan t
                WHERE
                    (t.judul ILIKE %s OR t.sinopsis_trailer ILIKE %s)
                    AND t.url_video_trailer IS NOT NULL
            """, [f'%{query}%', f'%{query}%'])
            trailer_results = [
                {
                    'title': row[0],
                    'synopsis': row[1],
                    'trailer_url': row[2],
                    'release_date': row[3]
                }
                for row in cursor.fetchall()
            ]

            # Search for films
            cursor.execute("""
                SELECT
                    t.judul AS title,
                    t.sinopsis_trailer AS synopsis,
                    t.url_video_trailer AS trailer_url,
                    f.release_date_film AS release_date
                FROM 
                    pacilflix.film f
                    JOIN pacilflix.tayangan t ON f.id_tayangan = t.id
                WHERE
                    t.judul ILIKE %s OR t.sinopsis_trailer ILIKE %s
            """, [f'%{query}%', f'%{query}%'])
            film_results = [
                {
                    'title': row[0],
                    'synopsis': row[1],
                    'trailer_url': row[2],
                    'release_date': row[3],
                }
                for row in cursor.fetchall()
            ]

            # Search for series
            cursor.execute("""
                SELECT
                    t.judul AS title,
                    t.sinopsis_trailer AS synopsis,
                    t.url_video_trailer AS trailer_url,
                    t.release_date_trailer AS release_date
                FROM 
                    pacilflix.series s
                    JOIN pacilflix.tayangan t ON s.id_tayangan = t.id
                WHERE
                    t.judul ILIKE %s OR t.sinopsis_trailer ILIKE %s
            """, [f'%{query}%', f'%{query}%'])
            series_results = [
                {
                    'title': row[0],
                    'synopsis': row[1],
                    'trailer_url': row[2],
                    'release_date': row[3],
                }
                for row in cursor.fetchall()
            ]

        context.update({
            'trailer_results': trailer_results,
            'film_results': film_results,
            'series_results': series_results,
        })

    return render(request, "hasilCariTrailer.html", context)