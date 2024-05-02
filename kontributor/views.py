from django.shortcuts import render

# Create your views here.
def show_kontributor(request):
    return render(request, "kontributor.html")