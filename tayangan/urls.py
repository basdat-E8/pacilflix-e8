from django.urls import path
from tayangan.views import *

app_name = 'tayangan'

urlpatterns = [
    path('', show_tayangan, name='show_tayangan'),
    path('search', show_tayangan_search, name='show_tayangan_search'),
    path('film/<uuid:id>/', show_halaman_film, name='show_halaman_film'),
    path('series/<uuid:id>/', show_halaman_series, name='show_halaman_series'),
    path('episode/<uuid:id_series>/<str:sub_judul>/', show_halaman_episode, name='show_halaman_episode'),
]