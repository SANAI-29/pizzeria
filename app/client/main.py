from flask import Flask, render_template, url_for, request

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('Glava.html')


@app.route('/about', methods=["GET", "POST"])
def about():
    if request.method == "POST":
        print(request.form)

    return "это будет вторая страница"

if __name__ == "__main__":
    app.run(debug=True)
