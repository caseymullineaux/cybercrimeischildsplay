import psycopg2
import psycopg2.extras
from flask import (
    Flask,
    render_template,
    request,
    redirect,
    url_for,
    flash,
)
from flask_login import (
    LoginManager,
    UserMixin,
    login_user,
    logout_user,
    login_required,
    current_user,
)
from functools import wraps
import os
import hashlib


# INSECURE: Using MD5 for password hashing (for demo purposes only!)
def generate_password_hash(password):
    """VULNERABLE: MD5 hashing is easily crackable - DO NOT USE IN PRODUCTION!"""
    return hashlib.md5(password.encode()).hexdigest()


def check_password_hash(hash_value, password):
    """Check if password matches MD5 hash"""
    return hash_value == hashlib.md5(password.encode()).hexdigest()


app = Flask(__name__)
# WARNING: This is intentionally insecure for demonstration purposes
app.secret_key = "insecure_secret_key_for_demo"
app.config["SESSION_COOKIE_HTTPONLY"] = (
    False  
)

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = "login"


# Database helper functions
def get_db():
    """Get PostgreSQL database connection"""
    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=os.environ.get("DB_PORT", "5432"),
        database=os.environ.get("DB_NAME", "typo_payments"),
        user=os.environ.get("DB_USER", "admin"),
        password=os.environ.get("DB_PASSWORD", "password123"),
    )
    return conn


class User(UserMixin):
    def __init__(self, id, username, email, full_name, is_admin=False):
        self.id = id
        self.username = username
        self.email = email
        self.full_name = full_name
        self.is_admin = is_admin


@login_manager.user_loader
def load_user(user_id):
    conn = get_db()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    if user:
        return User(
            user["id"],
            user["username"],
            user["email"],
            user["full_name"],
            user["is_admin"],
        )
    return None


def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not current_user.is_authenticated:
            flash("Please log in to access this page.", "error")
            return redirect(url_for("login"))
        if not current_user.is_admin:
            flash("You need administrator privileges to access this page.", "error")
            return redirect(url_for("dashboard"))
        return f(*args, **kwargs)

    return decorated_function


# Routes
@app.route("/")
def index():
    return render_template("index.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        username = request.form["username"]
        email = request.form["email"]
        password = request.form["password"]
        full_name = request.form["full_name"]

        conn = get_db()
        try:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO users (username, email, password_hash, full_name) VALUES (%s, %s, %s, %s)",
                (username, email, generate_password_hash(password), full_name),
            )
            conn.commit()
            flash("Registration successful! Please login.", "success")
            return redirect(url_for("login"))
        except psycopg2.IntegrityError:
            flash("Username or email already exists", "error")
            conn.rollback()
        finally:
            conn.close()

    return render_template("register.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        conn = get_db()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user and check_password_hash(user["password_hash"], password):
            user_obj = User(
                user["id"],
                user["username"],
                user["email"],
                user["full_name"],
                user["is_admin"],
            )
            login_user(user_obj)
            flash("Login successful!", "success")
            return redirect(url_for("dashboard"))
        else:
            flash("Invalid username or password", "error")

    return render_template("login.html")


@app.route("/logout")
@login_required
def logout():
    logout_user()
    flash("You have been logged out", "success")
    return redirect(url_for("index"))


@app.route("/dashboard")
@login_required
def dashboard():
    conn = get_db()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cursor.execute(
        "SELECT * FROM payments WHERE user_id = %s ORDER BY id DESC",
        (current_user.id,),
    )
    payments = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("dashboard.html", payments=payments)


@app.route("/search")
@login_required
def search():
    query = request.args.get("query", "")
    conn = get_db()
    conn.autocommit = True
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    error = None

    # VULNERABLE: SQL Injection via search query!
    sql = f"SELECT * FROM payments WHERE description ILIKE '%{query}%' AND user_id = {current_user.id}"

    try:
        cursor.execute(sql)
        results = cursor.fetchall()
    except Exception as e:
        results = []
        error = str(e)

    cursor.close()
    conn.close()

    return render_template(
        "search.html", query=query, results=results, sql_query=sql, error=error
    )


# VULNERABLE: Blind SQL Injection - payment status check
@app.route("/status")
@login_required
def check_status():
    payment_id = request.args.get("id", "")

    conn = get_db()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    payment = None
    sql_query = None

    if payment_id:
        try:
            # VULNERABLE: Blind SQL Injection via string formatting
            # Returns full payment details if TRUE, nothing if FALSE
            # Attackers can extract data by observing "Payment details shown" vs "Payment Not Found"
            query = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND id = {payment_id}"
            sql_query = query  # Store for debug display
            cursor.execute(query)
            payment = cursor.fetchone()

        except Exception:
            payment = None

    cursor.close()
    conn.close()

    return render_template(
        "status.html",
        payment=payment,
        payment_id=payment_id,
        sql_query=sql_query,
    )


# VULNERABLE: Stored XSS - feedback/comments
@app.route("/feedback", methods=["GET", "POST"])
@login_required
def feedback():
    if request.method == "POST":
        message = request.form["message"]

        conn = get_db()
        cursor = conn.cursor()
        # VULNERABLE: Storing unsanitized user input
        cursor.execute(
            "INSERT INTO feedback (user_id, username, message) VALUES (%s, %s, %s)",
            (current_user.id, current_user.username, message),
        )
        conn.commit()
        cursor.close()
        conn.close()

        flash("Thank you for your feedback!", "success")
        return redirect(url_for("feedback"))

    conn = get_db()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cursor.execute("SELECT * FROM feedback ORDER BY created_at DESC LIMIT 50")
    all_feedback = cursor.fetchall()
    cursor.close()
    conn.close()

    # VULNERABLE: Feedback will be rendered without escaping in template
    return render_template("feedback.html", feedback_list=all_feedback)


@app.route("/profile")
@login_required
def profile():
    return render_template("profile.html")


# Admin Routes
@app.route("/admin")
@admin_required
def admin_dashboard():
    conn = get_db()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cursor.execute("SELECT * FROM users ORDER BY created_at DESC")
    users = cursor.fetchall()
    user_count = len(users)
    cursor.execute("SELECT COUNT(*) as count FROM users WHERE is_admin = TRUE")
    admin_count = cursor.fetchone()["count"]
    cursor.execute("SELECT COUNT(*) as count FROM payments")
    payment_count = cursor.fetchone()["count"]
    cursor.execute("SELECT COUNT(*) as count FROM feedback")
    feedback_count = cursor.fetchone()["count"]
    cursor.close()
    conn.close()

    return render_template(
        "admin_dashboard.html",
        users=users,
        user_count=user_count,
        admin_count=admin_count,
        payment_count=payment_count,
        feedback_count=feedback_count,
    )


@app.route("/admin/users")
@admin_required
def admin_users():
    conn = get_db()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cursor.execute("SELECT * FROM users ORDER BY created_at DESC")
    users = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("admin_users.html", users=users)


@app.route("/admin/create-user", methods=["GET", "POST"])
@admin_required
def admin_create_user():
    if request.method == "POST":
        username = request.form["username"]
        email = request.form["email"]
        password = request.form["password"]
        full_name = request.form["full_name"]
        is_admin = True if request.form.get("is_admin") else False

        conn = get_db()
        try:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO users (username, email, password_hash, full_name, is_admin) VALUES (%s, %s, %s, %s, %s)",
                (
                    username,
                    email,
                    generate_password_hash(password),
                    full_name,
                    is_admin,
                ),
            )
            conn.commit()
            flash(f"User {username} created successfully!", "success")
            return redirect(url_for("admin_users"))
        except psycopg2.IntegrityError:
            flash("Username or email already exists", "error")
            conn.rollback()
        finally:
            cursor.close()
            conn.close()

    return render_template("admin_create_user.html")


@app.route("/admin/toggle-admin/<int:user_id>", methods=["POST"])
@admin_required
def toggle_admin(user_id):
    # Prevent removing your own admin rights
    if user_id == current_user.id:
        flash("You cannot modify your own admin status", "error")
        return redirect(url_for("admin_users"))

    conn = get_db()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()

    if user:
        new_status = False if user["is_admin"] else True
        cursor.execute(
            "UPDATE users SET is_admin = %s WHERE id = %s", (new_status, user_id)
        )
        conn.commit()

        status_text = "granted to" if new_status else "revoked from"
        flash(f"Admin privileges {status_text} {user['username']}", "success")
    else:
        flash("User not found", "error")

    cursor.close()
    conn.close()
    return redirect(url_for("admin_users"))


@app.route("/admin/delete-user/<int:user_id>", methods=["POST"])
@admin_required
def delete_user(user_id):
    # Prevent deleting yourself
    if user_id == current_user.id:
        flash("You cannot delete your own account", "error")
        return redirect(url_for("admin_users"))

    conn = get_db()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()

    if user:
        # Delete user's payments and feedback first
        cursor.execute("DELETE FROM payments WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM feedback WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
        conn.commit()
        flash(f"User {user['username']} and their data deleted successfully", "success")
    else:
        flash("User not found", "error")

    cursor.close()
    conn.close()
    return redirect(url_for("admin_users"))


@app.route("/admin/reset-database", methods=["POST"])
@admin_required
def reset_database_route():
    """Reset the entire database to initial demo state"""
    try:
        from reset_db import reset_database

        success = reset_database()

        if success:
            logout_user()
            flash(
                "Database has been reset to initial state. Please log in again.",
                "success",
            )
            return redirect(url_for("login"))
        else:
            flash("Failed to reset database. Check logs for details.", "error")
            return redirect(url_for("admin_dashboard"))
    except Exception as e:
        flash(f"Error resetting database: {str(e)}", "error")
        return redirect(url_for("admin_dashboard"))


if __name__ == "__main__":
    # Bind to 0.0.0.0 to allow access from outside the container
    app.run(debug=True, host="0.0.0.0", port=5000)
