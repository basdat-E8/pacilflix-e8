from django.urls import path
from unduhan.views import *

app_name = 'unduhan'

urlpatterns = [
    path('', show_daftar_unduhan, name='show_daftar_unduhan'),
    path('daftar', show_unduhan, name='show_unduhan')
]