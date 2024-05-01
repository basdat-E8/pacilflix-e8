from django.shortcuts import render

# Create your views here.

def show_daftar_favorit(request):
    return render(request, "show_daftar_favorit.html")