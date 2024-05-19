from django.urls import path
from kontributor.views import *

app_name = 'kontributor'

urlpatterns = [
    path('', show_kontributor, name='show_kontributor'),
    path('get-list/<str:filter_by>', get_daftar_kontributor, name='get_daftar_kontributor')
]