from django.db import connection
from django.shortcuts import render
from utils.query import query

# Create your views here.
def show_tayangan(request):
    context = {
        "is_logged_in": False
    }
    if "username" in request.session:
        context["is_logged_in"] = True
        context["username"] = request.session["username"]

    # Query for films
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                f.id_tayangan,
                t.judul AS title, 
                t.sinopsis AS synopsis, 
                t.url_video_trailer AS trailer_url, 
                f.release_date_film AS release_date
            FROM 
                pacilflix.film f
                JOIN pacilflix.tayangan t ON f.id_tayangan = t.id
        """)
        film_list = [
            {
                'id': row[0],
                'title': row[1],
                'synopsis': row[2],
                'trailer_url': row[3],
                'release_date': row[4],
            }
            for row in cursor.fetchall()
        ]

    # Query for series
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT
                s.id_tayangan,
                t.judul AS title, 
                t.sinopsis AS synopsis, 
                t.url_video_trailer AS trailer_url, 
                t.release_date_trailer AS release_date
            FROM 
                pacilflix.series s
                JOIN pacilflix.tayangan t ON s.id_tayangan = t.id
        """)
        series_list = [
            {
                'id': row[0],
                'title': row[1],
                'synopsis': row[2],
                'trailer_url': row[3],
                'release_date': row[4],
            }
            for row in cursor.fetchall()
        ]

    context.update({
        'film_list': film_list,
        'series_list': series_list
    })
    return render(request, "tayangan.html", context)

def show_halaman_film(request, id):
    with connection.cursor() as cursor:
        # Fetch film details
        cursor.execute("""
            SELECT
                t.judul AS title,
                t.sinopsis AS synopsis,
                f.durasi_film AS duration,
                f.release_date_film AS release_date,
                f.url_video_film AS film_url,
                t.asal_negara AS country,
                (SELECT c.nama FROM pacilflix.sutradara s JOIN pacilflix.contributors c ON s.id = c.id WHERE s.id = t.id_sutradara) AS director
            FROM
                pacilflix.tayangan t
                JOIN pacilflix.film f ON t.id = f.id_tayangan
            WHERE
                t.id = %s
        """, [id])
        film = cursor.fetchone()
        if film:
            film_data = {
                'title': film[0],
                'synopsis': film[1],
                'duration': film[2],
                'release_date': film[3],
                'film_url': film[4],
                'country': film[5],
                'director': film[6]
            }

        # Fetch genres
        cursor.execute("""
            SELECT g.genre
            FROM pacilflix.genre_tayangan g
            WHERE g.id_tayangan = %s
        """, [id])
        genres = cursor.fetchall()
        genre_list = [genre[0] for genre in genres]

        # Fetch cast
        cursor.execute("""
            SELECT c.nama
            FROM pacilflix.pemain p
            JOIN pacilflix.contributors c ON p.id = c.id
            JOIN pacilflix.memainkan_tayangan mt ON p.id = mt.id_pemain
            WHERE mt.id_tayangan = %s
        """, [id])
        cast = cursor.fetchall()
        cast_list = [actor[0] for actor in cast]

        # Fetch screenwriters
        cursor.execute("""
            SELECT c.nama
            FROM pacilflix.penulis_skenario ps
            JOIN pacilflix.contributors c ON ps.id = c.id
            JOIN pacilflix.menulis_skenario_tayangan mst ON ps.id = mst.id_penulis_skenario
            WHERE mst.id_tayangan = %s
        """, [id])
        screenwriters = cursor.fetchall()
        screenwriter_list = [writer[0] for writer in screenwriters]

    context = {
        'film_data': film_data,
        'genres': genre_list,
        'cast': cast_list,
        'screenwriters': screenwriter_list
    }
    return render(request, "halamanFilm.html", context)

def show_halaman_series(request, id):
    with connection.cursor() as cursor:
        # Fetch series details
        cursor.execute("""
            SELECT
                t.judul AS title,
                t.sinopsis AS synopsis,
                t.release_date_trailer AS release_date,
                t.url_video_trailer AS series_url,
                t.asal_negara AS country,
                (SELECT c.nama FROM pacilflix.sutradara s JOIN pacilflix.contributors c ON s.id = c.id WHERE s.id = t.id_sutradara) AS director
            FROM
                pacilflix.tayangan t
                JOIN pacilflix.series s ON t.id = s.id_tayangan
            WHERE
                t.id = %s
        """, [id])
        series = cursor.fetchone()
        if series:
            series_data = {
                'title': series[0],
                'synopsis': series[1],
                'release_date': series[2],
                'series_url': series[3],
                'country': series[4],
                'director': series[5]
            }

        # Fetch genres
        cursor.execute("""
            SELECT g.genre
            FROM pacilflix.genre_tayangan g
            WHERE g.id_tayangan = %s
        """, [id])
        genres = cursor.fetchall()
        genre_list = [genre[0] for genre in genres]

        # Fetch cast
        cursor.execute("""
            SELECT c.nama
            FROM pacilflix.pemain p
            JOIN pacilflix.contributors c ON p.id = c.id
            JOIN pacilflix.memainkan_tayangan mt ON p.id = mt.id_pemain
            WHERE mt.id_tayangan = %s
        """, [id])
        cast = cursor.fetchall()
        cast_list = [actor[0] for actor in cast]

        # Fetch screenwriters
        cursor.execute("""
            SELECT c.nama
            FROM pacilflix.penulis_skenario ps
            JOIN pacilflix.contributors c ON ps.id = c.id
            JOIN pacilflix.menulis_skenario_tayangan mst ON ps.id = mst.id_penulis_skenario
            WHERE mst.id_tayangan = %s
        """, [id])
        screenwriters = cursor.fetchall()
        screenwriter_list = [writer[0] for writer in screenwriters]

        # Fetch episodes
        cursor.execute("""
            SELECT e.id_series, e.sub_judul, e.sinopsis, e.durasi, e.url_video, e.release_date
            FROM pacilflix.episode e
            WHERE e.id_series = %s
        """, [id])
        episodes = cursor.fetchall()
        episode_list = [
            {
                'id_series': episode[0],
                'sub_title': episode[1],
                'synopsis': episode[2],
                'duration': episode[3],
                'url_video': episode[4],
                'release_date': episode[5],
            }
            for episode in episodes
        ]

    context = {
        'series_data': series_data,
        'genres': genre_list,
        'cast': cast_list,
        'screenwriters': screenwriter_list,
        'episodes': episode_list
    }
    return render(request, "halamanSeries.html", context)

def show_halaman_episode(request, id_series, sub_judul):
    with connection.cursor() as cursor:
        # Fetch episode details
        cursor.execute("""
            SELECT
                e.sub_judul AS subtitle,
                e.sinopsis AS synopsis,
                e.durasi AS duration,
                e.url_video AS episode_url,
                e.release_date AS release_date,
                t.judul AS series_title
            FROM
                pacilflix.episode e
                JOIN pacilflix.series s ON e.id_series = s.id_tayangan
                JOIN pacilflix.tayangan t ON s.id_tayangan = t.id
            WHERE
                e.id_series = %s AND e.sub_judul = %s
        """, [id_series, sub_judul])
        episode = cursor.fetchone()
        if episode:
            episode_data = {
                'subtitle': episode[0],
                'synopsis': episode[1],
                'duration': episode[2],
                'episode_url': episode[3],
                'release_date': episode[4],
                'series_title': episode[5],
            }

        # Fetch other episodes
        cursor.execute("""
            SELECT e.sub_judul
            FROM pacilflix.episode e
            WHERE e.id_series = %s AND e.sub_judul != %s
        """, [id_series, sub_judul])
        other_episodes = cursor.fetchall()
        other_episode_list = [ep[0] for ep in other_episodes]

    context = {
        'episode_data': episode_data,
        'other_episodes': other_episode_list,
    }
    return render(request, "halamanEpisode.html", context)

def show_tayangan_search(request):
    query = request.GET.get('q', '')
    context = {'query': query}

    if query:
        with connection.cursor() as cursor:
            # Search for films
            cursor.execute("""
                SELECT
                    f.id_tayangan,
                    t.judul AS title,
                    t.sinopsis AS synopsis,
                    t.url_video_trailer AS trailer_url,
                    f.release_date_film AS release_date
                FROM
                    pacilflix.film f
                    JOIN pacilflix.tayangan t ON f.id_tayangan = t.id
                WHERE
                    t.judul ILIKE %s OR t.sinopsis ILIKE %s
            """, [f'%{query}%', f'%{query}%'])
            film_results = [
                {
                    'id': row[0],
                    'title': row[1],
                    'synopsis': row[2],
                    'trailer_url': row[3],
                    'release_date': row[4],
                }
                for row in cursor.fetchall()
            ]

            # Search for series
            cursor.execute("""
                SELECT
                    s.id_tayangan,
                    t.judul AS title,
                    t.sinopsis AS synopsis,
                    t.url_video_trailer AS trailer_url,
                    t.release_date_trailer AS release_date
                FROM
                    pacilflix.series s
                    JOIN pacilflix.tayangan t ON s.id_tayangan = t.id
                WHERE
                    t.judul ILIKE %s OR t.sinopsis ILIKE %s
            """, [f'%{query}%', f'%{query}%'])
            series_results = [
                {
                    'id': row[0],
                    'title': row[1],
                    'synopsis': row[2],
                    'trailer_url': row[3],
                    'release_date': row[4],
                }
                for row in cursor.fetchall()
            ]

        context.update({
            'film_results': film_results,
            'series_results': series_results,
        })

    return render(request, "hasilCariTayangan.html", context)