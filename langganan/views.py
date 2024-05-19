from utils.query import *
from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

import datetime
import json

# Create your views here.
def logged_in(request):
    return request.session.get('username', None) is not None and request.session.get('is_logged_in', False)

def show_langganan(request):
    if not logged_in(request):
        return redirect("authentication:logout")
    
    response = {
        "is_logged_in": True
    }

    return render(request, "kelola_langganan.html", response)

def show_beli_langganan(request, paket):
    if not logged_in(request):
        return redirect("authentication:logout")
    
    response = {
        "paket": paket,
        "is_logged_in": True
    }

    return render(request, "beli_langganan.html", response)

@csrf_exempt
def beli_langganan(request):
    if not logged_in(request):
        return redirect("authentication:logout")
    
    body = json.loads(request.body)
    paket = body.get("paket", None)
    metode_pembayaran = body.get("metode_pembayaran", None)

    if not paket or not metode_pembayaran:
        return JsonResponse({"status": "error", "message": "Missing required fields"}, status=400, safe=False)

    if request.method == "POST":
        # Insert new subscription
        query_str = """
            INSERT INTO 
            TRANSACTION (username, start_date_time, end_date_time, nama_paket, metode_pembayaran, timestamp_pembayaran)
            VALUES (%s, %s, %s, %s, %s, %s)
        """

        username = request.session.get('username', None)
        start_date_time = datetime.datetime.now().strftime("%Y-%m-%d")
        end_date_time = (datetime.datetime.now() + datetime.timedelta(days=30)).strftime("%Y-%m-%d")
        nama_paket = paket
        metode_pembayaran = metode_pembayaran
        timestamp_pembayaran = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        res = query(query_str, (
                username, 
                start_date_time, 
                end_date_time, 
                nama_paket, 
                metode_pembayaran, 
                timestamp_pembayaran
            )
        )

        print(res)

        if isinstance(res, Exception):
            query_str = "SELECT sp_beli_langganan(%s, %s, %s, %s, %s, %s)"
            timestamp_pembayaran = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            res = query(query_str, (
                    username, 
                    start_date_time, 
                    end_date_time, 
                    nama_paket, 
                    metode_pembayaran, 
                    timestamp_pembayaran
                )
            )

            print(res)

        return JsonResponse({"status": "success"}, status=200, safe=False)

    return JsonResponse({"status": "error", "message": "Method not allowed"}, status=405, safe=False)


def get_detail_paket(request, paket):
    if not logged_in(request):
        return redirect("authentication:logout")
    
    if request.method == "GET":
        query_str = f"""
            SELECT
                p.nama,
                p.harga,
                dp.dukungan_perangkat,
                p.resolusi_layar
            FROM
                PAKET p
            JOIN
                DUKUNGAN_PERANGKAT dp ON p.nama = dp.nama_paket
            WHERE
                p.nama = '{paket}'
        """

        data = query(query_str)

        response = {}
        response["data"] = data

        return JsonResponse(response, status=200, safe=False)
    return JsonResponse({"status": "error", "message": "Method not allowed"}, status=405, safe=False)

def get_riwayat_transaksi(request):
    if not logged_in(request):
        return redirect("authentication:logout")
    
    username = request.session.get('username', None)
    response = {}
    if request.method == "GET":
        query_str = f"""
            SELECT 
                t.*,
                p.harga
            FROM 
                TRANSACTION t
            JOIN
                PAKET p ON t.nama_paket = p.nama
            WHERE
                t.username = '{username}'
        """

        data = query(query_str)
        response["data"] = data
        response["status"] = "success"

        return JsonResponse(response, status=200, safe=False)

    return JsonResponse({"status": "error", "message": "Method not allowed"}, status=405, safe=False)

def get_daftar_paket(request):
    if not logged_in(request):
        return redirect("authentication:logout")
    
    if request.method == "GET":
        response = {}
        query_str = """
            SELECT
                p.nama,
                p.harga,
                dp.dukungan_perangkat,
                p.resolusi_layar
            FROM
                PAKET p
            JOIN
                DUKUNGAN_PERANGKAT dp ON p.nama = dp.nama_paket
        """
        data = query(query_str)
        response["data"] = data
        response["status"] = "success"

        return JsonResponse(response, status=200, safe=False)
    
    return JsonResponse({"status": "error", "message": "Method not allowed"}, status=405, safe=False)

def get_langganan_aktif_user(request):
    if not logged_in(request):
        return redirect("authentication:logout")
    
    username = request.session.get('username')
    if request.method == "GET":
        response = {}
        query_str = f"""
            SELECT
                t.nama_paket,
                p.harga,
                p.resolusi_layar,
                dp.dukungan_perangkat,
                t.start_date_time,
                t.end_date_time
            FROM
                TRANSACTION t
            JOIN
                PENGGUNA u ON t.username = u.username
            JOIN
                PAKET p ON t.nama_paket = p.nama
            JOIN
                DUKUNGAN_PERANGKAT dp ON t.nama_paket = dp.nama_paket
            WHERE
                u.username = '{username}' 
                AND t.end_date_time >= '{datetime.datetime.now().strftime("%Y-%m-%d")}'
            ORDER BY
                t.timestamp_pembayaran DESC
            LIMIT 1
        """
        data = query(query_str)
        response["data"] = data 
        response["status"] = "success"

        return JsonResponse(response, status=200, safe=False)
    
    return JsonResponse({"status": "error", "message": "Method not allowed"}, status=405, safe=False)