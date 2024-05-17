from django.shortcuts import render, redirect

# Create your views here.

def show_landing(request):
    context = {
        "is_logged_in": False
    }
    if 'username' in request.session:
        context["is_logged_in"] = True
        context["username"] = request.session["username"]
        return redirect("tayangan:show_tayangan")

    return render(request, "landingpage.html", context)