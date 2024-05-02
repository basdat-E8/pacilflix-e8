from django.urls import path
from trailer.views import *

app_name = 'trailer'

urlpatterns = [
    path('', show_trailers, name='show_trailers'),
    path('search', show_trailer_search, name='show_trailer_search')
]