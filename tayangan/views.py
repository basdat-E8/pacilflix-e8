from django.shortcuts import render

# Create your views here.
def show_tayangan(request):
    return render(request, "tayangan.html")

def show_tayangan_search(request):
    return render(request, "hasilCariTayangan.html")

def show_halaman_film(request):
    return render(request, 'halamanFilm.html')

def show_halaman_series(request):
    return render(request, 'halamanSeries.html')

def show_halaman_episode(request):
    return render(request, 'halamanEpisode.html')