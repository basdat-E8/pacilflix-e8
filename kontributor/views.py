from utils.query import *
from django.shortcuts import render, redirect
from django.http import JsonResponse

# Create your views here.
def logged_in(request):
    return request.session.get('username', None) is not None

def show_kontributor(request, id_tayangan):
    if not logged_in(request):
        return redirect("authentication:login")
    
    response = {
        "id_tayangan": id_tayangan
    }

    return render(request, 'kontributor.html', response)

def get_daftar_kontributor(request, id_tayangan, filter_by):
    if not logged_in(request):
        return redirect("authentication:login")
    
    if request.method == 'GET':
        response = {}
        
        if filter_by == "none":
            contributors = []
            sql_query = f"""
                SELECT 
                    c.nama, 
                    'Penulis Skenario' AS tipe, 
                    CASE 
                        WHEN c.jenis_kelamin = 0 THEN 'male'
                        WHEN c.jenis_kelamin = 1 THEN 'female'
                    END AS jenis_kelamin, 
                    c.kewarganegaraan
                FROM 
                    contributors c
                JOIN 
                    penulis_skenario p ON c.id = p.id
                JOIN
                    MENULIS_SKENARIO_TAYANGAN mt ON c.id = mt.id_penulis_skenario
                WHERE
                    mt.id_tayangan = '{id_tayangan}'

                UNION ALL

                SELECT 
                    c.nama, 
                    'Pemain' AS tipe, 
                    CASE 
                        WHEN c.jenis_kelamin = 0 THEN 'male'
                        WHEN c.jenis_kelamin = 1 THEN 'female'
                    END AS jenis_kelamin, 
                    c.kewarganegaraan
                FROM 
                    contributors c
                JOIN 
                    pemain pm ON c.id = pm.id
                JOIN
                    MEMAINKAN_TAYANGAN mt ON c.id = mt.id_pemain
                WHERE
                    mt.id_tayangan = '{id_tayangan}'

                UNION ALL

                SELECT 
                    c.nama, 
                    'Sutradara' AS tipe, 
                    CASE 
                        WHEN c.jenis_kelamin = 0 THEN 'male'
                        WHEN c.jenis_kelamin = 1 THEN 'female'
                    END AS jenis_kelamin, 
                    c.kewarganegaraan
                FROM 
                    contributors c
                JOIN 
                    sutradara s ON c.id = s.id
                JOIN
                    TAYANGAN t ON c.id = t.id_sutradara
                WHERE
                    t.id = '{id_tayangan}'

            """
        else:
            filter_by = filter_by.upper()
            type = ' '.join(filter_by.replace("_"," ").title().split())
            table = {
                'PENULIS_SKENARIO': f"""
                    JOIN
                        MENULIS_SKENARIO_TAYANGAN mt ON c.id = mt.id_penulis_skenario
                    WHERE
                        mt.id_tayangan = '{id_tayangan}'
                """,

                'PEMAIN': f"""
                    JOIN
                        MEMAINKAN_TAYANGAN mt ON c.id = mt.id_pemain
                    WHERE
                        mt.id_tayangan = '{id_tayangan}'
                """,

                'SUTRADARA': f"""
                    JOIN
                        TAYANGAN t ON c.id = t.id_sutradara
                    WHERE
                        t.id = '{id_tayangan}'
                """
            }

            sql_query = f"""
                SELECT 
                    c.nama, 
                    '{type}' AS tipe, 
                    CASE 
                        WHEN c.jenis_kelamin = 0 THEN 'male'
                        WHEN c.jenis_kelamin = 1 THEN 'female'
                    END AS jenis_kelamin, 
                    c.kewarganegaraan
                FROM 
                    contributors c
                JOIN 
                    {filter_by} f ON c.id = f.id
                {table[filter_by]}
            """

        contributors = query(sql_query)

        response["status"] = "success"
        response["data"] = contributors

        return JsonResponse(response, status=200, safe=False)
    
    return JsonResponse({"status": "error", "message": "Method not allowed"}, status=405, safe=False)