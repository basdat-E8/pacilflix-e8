from django.db import connection
from django.shortcuts import render, redirect
from utils.query import query
from django.utils import timezone

# Create your views here.
def show_tayangan(request):
    context = {
        "is_logged_in": False
    }
    if 'username' not in request.session:
        return redirect("main:show_landing")
    else:
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

        # Query for films
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
        'list_top_tayangan': list_top_tayangan,
        'film_list': film_list,
        'series_list': series_list
    })
    return render(request, "tayangan.html", context)

def show_halaman_film(request, id):
    context = {
        "is_logged_in": False
    }
    if 'username' not in request.session:
        return redirect("main:show_landing")
    else:
        context["is_logged_in"] = True
        context["username"] = request.session["username"]

    if request.method == "POST":
        review_description = request.POST.get('reviewDescription')
        rating = request.POST.get('rating')
        username = request.session.get('username')

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT COUNT(*) FROM pacilflix.ulasan
                WHERE id_tayangan = %s AND username = %s
            """, [id, username])
            review_count = cursor.fetchone()[0]

            if review_count > 0:
                context['error_message'] = "Anda sudah memberikan ulasan pada film ini."
            else:
                cursor.execute("""
                    INSERT INTO pacilflix.ulasan (id_tayangan, rating, deskripsi, timestamp, username)
                    VALUES (%s, %s, %s, %s, %s)
                """, [id, rating, review_description, timezone.now(), username])
                return redirect('tayangan:show_halaman_film', id=id)

    with connection.cursor() as cursor:
        # Fetch film details
        cursor.execute("""
            SELECT
                t.id,
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
                'id': film[0],
                'title': film[1],
                'synopsis': film[2],
                'duration': film[3],
                'release_date': film[4],
                'film_url': film[5],
                'country': film[6],
                'director': film[7]
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

        # Fetch reviews
        cursor.execute("""
            SELECT
                t.judul AS title,
                ul.rating,
                ul.deskripsi AS description,
                ul.timestamp,
                ul.username
            FROM
                pacilflix.ulasan ul
                JOIN pacilflix.tayangan t ON ul.id_tayangan = t.id
            WHERE
                ul.id_tayangan = %s
            ORDER BY
                ul.timestamp DESC
        """, [id])
        reviews = [
            {
                'title': row[0],
                'rating': row[1],
                'description': row[2],
                'timestamp': row[3],
                'username': row[4]
            }
            for row in cursor.fetchall()
        ]

        # Get Total View Film
        cursor.execute(rf"""
            SET search_path to pacilflix; 
            SELECT COALESCE(
            (SELECT COUNT(*) FROM riwayat_nonton
            WHERE id_tayangan='{id}')
            ,
            0
            ) as count
        """)
        total_views = cursor.fetchone()[0]

        # Get Average Rating Film
        cursor.execute(rf"""
            SET search_path to pacilflix;
            SELECT COALESCE(
            (SELECT AVG(rating) FROM ulasan
            WHERE id_tayangan='{id}')
            ,
            0
            ) AS avg
        """)
        rating_avg = float(cursor.fetchone()[0])

    context.update({
        'film_data': film_data,
        'genres': genre_list,
        'cast': cast_list,
        'screenwriters': screenwriter_list,
        'reviews': reviews,
        'total_views': total_views,
        'rating_avg': rating_avg
    })
    return render(request, "halamanFilm.html", context)

def show_halaman_series(request, id):
    context = {
        "is_logged_in": False
    }
    if 'username' not in request.session:
        return redirect("main:show_landing")
    else:
        context["is_logged_in"] = True
        context["username"] = request.session["username"]

    if request.method == "POST":
        review_description = request.POST.get('reviewDescription')
        rating = request.POST.get('rating')
        username = request.session.get('username')

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT COUNT(*) FROM pacilflix.ulasan
                WHERE id_tayangan = %s AND username = %s
            """, [id, username])
            review_count = cursor.fetchone()[0]

            if review_count > 0:
                context['error_message'] = "Anda sudah pernah memberikan ulasan pada series ini."
            else:
                cursor.execute("""
                    INSERT INTO pacilflix.ulasan (id_tayangan, rating, deskripsi, timestamp, username)
                    VALUES (%s, %s, %s, %s, %s)
                """, [id, rating, review_description, timezone.now(), username])
                return redirect('tayangan:show_halaman_series', id=id)

    with connection.cursor() as cursor:
        # Fetch series details
        cursor.execute("""
            SELECT
                t.id,
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
                'id': series[0],
                'title': series[1],
                'synopsis': series[2],
                'release_date': series[3],
                'series_url': series[4],
                'country': series[5],
                'director': series[6]
            }

        # Fetch total views for the series
        cursor.execute(rf"""
        SET search_path to pacilflix; 
        SELECT COALESCE(
        (SELECT COUNT(*) FROM riwayat_nonton
        WHERE id_tayangan='{id}')
        ,
        0
        ) as count
        """)
        total_views = cursor.fetchone()[0]

        # Fetch average rating for the series
        cursor.execute(rf"""
        SET search_path to pacilflix;
        SELECT COALESCE(
        (SELECT AVG(rating) FROM ulasan
        WHERE id_tayangan='{id}')
        ,
        0
        ) AS avg
        """)
        rating_avg = float(cursor.fetchone()[0])

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

        # Fetch reviews
        cursor.execute("""
            SELECT
                t.judul AS title,
                ul.rating,
                ul.deskripsi AS description,
                ul.timestamp,
                ul.username
            FROM
                pacilflix.ulasan ul
                JOIN pacilflix.tayangan t ON ul.id_tayangan = t.id
            WHERE
                ul.id_tayangan = %s
            ORDER BY
                ul.timestamp DESC
        """, [id])
        reviews = [
            {
                'title': row[0],
                'rating': row[1],
                'description': row[2],
                'timestamp': row[3],
                'username': row[4]
            }
            for row in cursor.fetchall()
        ]

    context.update({
        'series_data': series_data,
        'total_views': total_views,
        'rating_avg': rating_avg,
        'genres': genre_list,
        'cast': cast_list,
        'screenwriters': screenwriter_list,
        'episodes': episode_list,
        'reviews': reviews
    })
    return render(request, "halamanSeries.html", context)

def show_halaman_episode(request, id_series, sub_judul):
    context = {
        "is_logged_in": False
    }
    if 'username' not in request.session:
        return redirect("main:show_landing")
    else:
        context["is_logged_in"] = True
        context["username"] = request.session["username"]

    with connection.cursor() as cursor:
        # Fetch episode details
        cursor.execute("""
            SELECT
                e.sub_judul AS subtitle,
                e.sinopsis AS synopsis,
                e.durasi AS duration,
                e.url_video AS episode_url,
                e.release_date AS release_date,
                t.judul AS series_title,
                e.id_series AS series_id
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
                'series_id': episode[6]
            }

        # Fetch other episodes
        cursor.execute("""
            SELECT e.sub_judul
            FROM pacilflix.episode e
            WHERE e.id_series = %s AND e.sub_judul != %s
        """, [id_series, sub_judul])
        other_episodes = cursor.fetchall()
        other_episode_list = [ep[0] for ep in other_episodes]

        # Fetch genres
        cursor.execute("""
            SELECT g.genre
            FROM pacilflix.genre_tayangan g
            WHERE g.id_tayangan = %s
        """, [id_series])
        genres = cursor.fetchall()
        genre_list = [genre[0] for genre in genres]

        # Fetch cast
        cursor.execute("""
            SELECT c.nama
            FROM pacilflix.pemain p
            JOIN pacilflix.contributors c ON p.id = c.id
            JOIN pacilflix.memainkan_tayangan mt ON p.id = mt.id_pemain
            WHERE mt.id_tayangan = %s
        """, [id_series])
        cast = cursor.fetchall()
        cast_list = [actor[0] for actor in cast]

        # Fetch screenwriters
        cursor.execute("""
            SELECT c.nama
            FROM pacilflix.penulis_skenario ps
            JOIN pacilflix.contributors c ON ps.id = c.id
            JOIN pacilflix.menulis_skenario_tayangan mst ON ps.id = mst.id_penulis_skenario
            WHERE mst.id_tayangan = %s
        """, [id_series])
        screenwriters = cursor.fetchall()
        screenwriter_list = [writer[0] for writer in screenwriters]

        # Fetch reviews
        cursor.execute("""
            SELECT
                e.sub_judul AS title,
                ul.rating,
                ul.deskripsi AS description,
                ul.timestamp,
                ul.username
            FROM
                pacilflix.ulasan ul
                JOIN pacilflix.episode e ON ul.id_tayangan = e.id_series
            WHERE
                ul.id_tayangan = %s AND e.sub_judul = %s
            ORDER BY
                ul.timestamp DESC
        """, [id_series, sub_judul])
        reviews = [
            {
                'title': row[0],
                'rating': row[1],
                'description': row[2],
                'timestamp': row[3],
                'username': row[4]
            }
            for row in cursor.fetchall()
        ]

    context = {
        'episode_data': episode_data,
        'other_episodes': other_episode_list,
        'genres': genre_list,
        'cast': cast_list,
        'screenwriters': screenwriter_list,
        'reviews': reviews
    }
    return render(request, "halamanEpisode.html", context)

def show_tayangan_search(request):
    context = {
        "is_logged_in": False
    }
    if 'username' not in request.session:
        return redirect("main:show_landing")
    else:
        context["is_logged_in"] = True
        context["username"] = request.session["username"]
    
    query = request.GET.get('q', '')
    context['query'] = query

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
                    'release_date': row[4].strftime("%Y-%m-%d") if row[4] else 'N/A',
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
                    'release_date': row[4].strftime("%Y-%m-%d") if row[4] else 'N/A',
                }
                for row in cursor.fetchall()
            ]

        context.update({
            'film_results': film_results,
            'series_results': series_results,
        })

    return render(request, "hasilCariTayangan.html", context)

def parse_tuple_to_dict(data, columns):
    return [dict(zip(columns, row)) for row in data]
