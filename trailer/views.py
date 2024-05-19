from django.db import connection
from django.shortcuts import render

def parse_tuple_to_dict(data, columns):
    return [dict(zip(columns, row)) for row in data]

def show_trailers(request):
    context = {
        "is_logged_in": False
    }
    if "username" in request.session:
        context["is_logged_in"] = True
        context["username"] = request.session["username"]

    isGlobal = request.GET.get('isGlobal', '1') == '1'
    asal_negara = request.COOKIES.get('negara_asal')

    with connection.cursor() as cursor:
        if isGlobal:
            query = """
                SET search_path TO pacilflix;

                WITH film_durasi AS (
                    SELECT id_tayangan, durasi_film AS durasi, 'film' AS source
                    FROM film
                ), 
                episode_durasi AS (
                    SELECT id_series AS id_tayangan, SUM(durasi) AS durasi, 'series' AS source
                    FROM episode
                    GROUP BY id_series
                ), 
                tayangan_durasi AS (
                    SELECT 
                        R.*, 
                        COALESCE(F.durasi, E.durasi) AS durasi,
                        COALESCE(F.source, E.source) AS source,
                        EXTRACT(EPOCH FROM (R.end_date_time - R.start_date_time)) / 60 AS time_diff 
                    FROM 
                        riwayat_nonton R
                    LEFT JOIN 
                        film_durasi F ON R.id_tayangan = F.id_tayangan
                    LEFT JOIN 
                        episode_durasi E ON R.id_tayangan = E.id_tayangan
                )

                SELECT 
                    TD.source,
                    TD.id_tayangan,
                    COUNT(*),
                    T.*
                FROM riwayat_nonton R
                LEFT JOIN tayangan_durasi TD ON R.id_tayangan = TD.id_tayangan
                LEFT JOIN tayangan T on T.id = TD.id_tayangan
                WHERE 
                    TD.time_diff >= (TD.durasi * 70 / 100) AND 
                    R.end_date_time >= NOW() - INTERVAL '7 days'
                GROUP BY TD.id_tayangan, T.id, TD.source
                ORDER BY COUNT(*) DESC
                LIMIT 10;
            """
        else:
            query = f"""
                SET search_path TO pacilflix;

                WITH film_durasi AS (
                    SELECT id_tayangan, durasi_film AS durasi, 'film' AS source
                    FROM film
                ), 
                episode_durasi AS (
                    SELECT id_series AS id_tayangan, SUM(durasi) AS durasi, 'series' AS source
                    FROM episode
                    GROUP BY id_series
                ), 
                tayangan_durasi AS (
                    SELECT 
                        R.*, 
                        COALESCE(F.durasi, E.durasi) AS durasi,
                        COALESCE(F.source, E.source) AS source,
                        EXTRACT(EPOCH FROM (R.end_date_time - R.start_date_time)) / 60 AS time_diff 
                    FROM 
                        riwayat_nonton R
                    LEFT JOIN 
                        film_durasi F ON R.id_tayangan = F.id_tayangan
                    LEFT JOIN 
                        episode_durasi E ON R.id_tayangan = E.id_tayangan
                )

                SELECT 
                    TD.source,
                    TD.id_tayangan,
                    COUNT(*),
                    T.*
                FROM riwayat_nonton R
                LEFT JOIN tayangan_durasi TD ON R.id_tayangan = TD.id_tayangan
                LEFT JOIN tayangan T on T.id = TD.id_tayangan
                WHERE 
                    TD.time_diff >= (TD.durasi * 70 / 100) AND 
                    R.end_date_time >= NOW() - INTERVAL '7 days' AND
                    T.asal_negara = '{asal_negara}'
                GROUP BY TD.id_tayangan, T.id, TD.source
                ORDER BY COUNT(*) DESC
                LIMIT 10;
            """

        # Top Tayangan
        cursor.execute(query)
        columns = ("source","id_tayangan","count","id","judul","sinopsis","asal_negara","sinopsis_trailer","url_video_trailer","release_date_trailer","id_sutradara")
        list_top_tayangan = parse_tuple_to_dict(cursor.fetchall(), columns)

        # Semua Film
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
            list_film = [
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
            list_series = [
                {
                    'title': row[0],
                    'synopsis': row[1],
                    'trailer_url': row[2],
                    'release_date': row[3],
                }
                for row in cursor.fetchall()
            ]

    context.update({
        'list_top_tayangan': list_top_tayangan,
        'list_film': list_film,
        'list_series': list_series
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