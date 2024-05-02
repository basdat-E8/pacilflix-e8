from django.shortcuts import render

# Create your views here.
def show_trailers(request):
    return render(request, "trailer.html")

def show_trailer_search(request):
    return render(request, "hasilCariTrailer.html")