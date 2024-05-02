from django.urls import path
from favorit.views import show_daftar_favorit

app_name = 'favorit'

urlpatterns = [
    path('', show_daftar_favorit, name='show_daftar_favorit'),
]