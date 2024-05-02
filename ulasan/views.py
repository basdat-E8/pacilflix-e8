from django.shortcuts import render

# Create your views here.
def show_ulasan(request):
    return render(request, "ulasan.html")