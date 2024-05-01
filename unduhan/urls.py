from django.urls import path
from unduhan.views import show_daftar_unduhan

app_name = 'unduhan'

urlpatterns = [
    path('', show_daftar_unduhan, name='show_daftar_unduhan'),
    
]