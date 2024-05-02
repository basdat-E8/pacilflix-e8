from django.urls import path
from tayangan.views import *

app_name = 'tayangan'

urlpatterns = [
    path('', show_tayangan, name='show_trailers'),
    path('search', show_tayangan_search, name='show_trailer_search'),
    path('film', show_halaman_film, name='show_halaman_film'),
    path('series', show_halaman_series, name='show_halaman_series'),
    path('episode', show_halaman_episode, name='show_halaman_episode'),
]