from django.shortcuts import render

# Create your views here.

def show_langganan(request):
    return render(request, "kelola_langganan.html")

def show_beli_langganan(request):
    return render(request, "beli_langganan.html")