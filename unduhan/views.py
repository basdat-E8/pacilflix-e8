from django.shortcuts import render

# Create your views here.
def show_daftar_unduhan(request):
    return render(request, "daftar_unduhan.html")