from django.shortcuts import render, redirect
from utils.query import query

# Create your views here.

def login(request):
    context = {}
    if "username" in request.session:
        return redirect("tayangan:show_tayangan")
    if "message" in request.session:
        context["message"] = request.session["message"]
        del request.session["message"]
    if request.method == "POST":
        username = request.POST.get('username')
        password = request.POST.get('password')

        username_exist = query("SELECT username from pengguna WHERE username = %s", (username,))
        user = query("SELECT username, password FROM pengguna WHERE username = %s AND password = %s", (username, password))
                
        if len(user) == 1:
            request.session['username'] = username
            return redirect("tayangan:show_tayangan")
        elif username_exist :
            context['message'] = "Password salah"
        else:
            context['message'] = "Tidak ada Username"
    
    return render(request, 'login.html', context)

def register(request):
    context = {}
    if "username" in request.session:
        return redirect("tayangan:show_tayangan")
    if request.method == "POST":
        username = request.POST.get('username')
        password = request.POST.get('password')
        negara_asal = request.POST.get('asal_negara')
        
        tes = query("INSERT INTO pengguna (username, password, negara_asal) VALUES (%s, %s, %s)", (username, password, negara_asal))
        if isinstance(tes, Exception): 
            context['message'] = "Username sudah ada. Silakan coba lagi"
        else:
            request.session['username'] = username
            return redirect('authentication:login')
    
    return render(request, 'register.html', context)

def logout(request):
    if 'username' in request.session:
        del request.session['username']

    return redirect('main:show_landing')