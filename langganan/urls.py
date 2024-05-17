from django.urls import path
from langganan.views import *

app_name = 'langganan'

urlpatterns = [
    path('', show_langganan, name='show_langganan'),
    path('get-langganan/', get_langganan_aktif_user, name='get_langganan_user'),
    path('get-paket/', get_daftar_paket, name='get_daftar_paket'),
    path('get-riwayat/', get_riwayat_transaksi, name='get_riwayat_transaksi'),

    path('beli/<str:paket>', show_beli_langganan, name='show_beli_langganan'),
    path('beli/get-detail/<str:paket>', get_detail_paket, name='get_detail_paket'),
    path('beli/process/', beli_langganan, name='submit_langganan'),
]